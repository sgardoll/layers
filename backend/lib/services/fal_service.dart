import 'dart:convert';
import 'package:http/http.dart' as http;

/// Response from fal.ai queue submission
class FalQueueResponse {
  final String requestId;
  final String status;

  FalQueueResponse({required this.requestId, required this.status});

  factory FalQueueResponse.fromJson(Map<String, dynamic> json) {
    return FalQueueResponse(
      requestId: json['request_id'] as String,
      status: json['status'] as String? ?? 'IN_QUEUE',
    );
  }
}

/// Status response from fal.ai
class FalStatusResponse {
  final String status; // IN_QUEUE, IN_PROGRESS, COMPLETED, FAILED
  final double? progress;
  final Map<String, dynamic>? result;
  final String? error;

  FalStatusResponse({
    required this.status,
    this.progress,
    this.result,
    this.error,
  });

  factory FalStatusResponse.fromJson(Map<String, dynamic> json) {
    return FalStatusResponse(
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toDouble(),
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isProcessing => status == 'IN_PROGRESS' || status == 'IN_QUEUE';
}

/// Layer data from fal.ai response
class FalLayer {
  final String url;
  final int width;
  final int height;

  FalLayer({required this.url, required this.width, required this.height});

  factory FalLayer.fromJson(Map<String, dynamic> json) {
    return FalLayer(
      url: json['url'] as String,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
    );
  }
}

/// Service for interacting with fal.ai Qwen-Image-Layered API
class FalService {
  static const String _baseUrl = 'https://queue.fal.run';
  static const String _modelId = 'fal-ai/qwen-image-layered';

  final String apiKey;
  final http.Client _client;

  FalService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': 'Key $apiKey',
    'Content-Type': 'application/json',
  };

  /// Submit an image for layer separation
  /// Returns the fal.ai request_id for polling
  Future<FalQueueResponse> submitJob({
    required String imageUrl,
    int numInferenceSteps = 28,
    double guidanceScale = 5.0,
  }) async {
    final url = Uri.parse('$_baseUrl/$_modelId');

    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'image_url': imageUrl,
        'num_inference_steps': numInferenceSteps,
        'guidance_scale': guidanceScale,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw FalServiceException(
        'Failed to submit job: ${response.statusCode}',
        response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return FalQueueResponse.fromJson(json);
  }

  /// Check the status of a submitted job
  Future<FalStatusResponse> checkStatus(String requestId) async {
    final url = Uri.parse('$_baseUrl/$_modelId/requests/$requestId/status');

    final response = await _client.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw FalServiceException(
        'Failed to check status: ${response.statusCode}',
        response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return FalStatusResponse.fromJson(json);
  }

  /// Get the result of a completed job
  Future<List<FalLayer>> getResult(String requestId) async {
    final url = Uri.parse('$_baseUrl/$_modelId/requests/$requestId');

    final response = await _client.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw FalServiceException(
        'Failed to get result: ${response.statusCode}',
        response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final layers = json['layers'] as List<dynamic>? ?? [];

    return layers
        .map((l) => FalLayer.fromJson(l as Map<String, dynamic>))
        .toList();
  }

  /// Cancel a pending job
  Future<void> cancelJob(String requestId) async {
    final url = Uri.parse('$_baseUrl/$_modelId/requests/$requestId/cancel');

    final response = await _client.put(url, headers: _headers);

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw FalServiceException(
        'Failed to cancel job: ${response.statusCode}',
        response.body,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class FalServiceException implements Exception {
  final String message;
  final String? details;

  FalServiceException(this.message, [this.details]);

  @override
  String toString() =>
      'FalServiceException: $message${details != null ? '\n$details' : ''}';
}
