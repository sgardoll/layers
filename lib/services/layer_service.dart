import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/result.dart';

class JobResponse {
  final String id;
  final String status;
  final String? error;
  final List<LayerData>? layers;

  JobResponse({
    required this.id,
    required this.status,
    this.error,
    this.layers,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      error: json['error'] as String?,
      layers: json['layers'] != null
          ? (json['layers'] as List)
                .map((l) => LayerData.fromJson(l as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isFinished => isCompleted || isFailed;
}

class LayerData {
  final int index;
  final String imageUrl;
  final int width;
  final int height;

  LayerData({
    required this.index,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  factory LayerData.fromJson(Map<String, dynamic> json) {
    return LayerData(
      index: json['index'] as int,
      imageUrl: json['image_url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }
}

class LayerService {
  final Dio _dio;
  final String _baseUrl;

  LayerService({required Dio dio, required String baseUrl})
    : _dio = dio,
      _baseUrl = baseUrl;

  Future<Result<JobResponse>> submitImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(image.path);

      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/api/jobs',
        data: {'image': 'data:$mimeType;base64,$base64Image'},
      );

      return Result.success(JobResponse.fromJson(response.data!));
    } on DioException catch (e) {
      return Result.failure(_extractError(e), e);
    } catch (e) {
      return Result.failure(e.toString(), e);
    }
  }

  Future<Result<JobResponse>> submitImageBytes(
    Uint8List bytes, {
    String mimeType = 'image/png',
  }) async {
    try {
      final base64Image = base64Encode(bytes);

      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/api/jobs',
        data: {'image': 'data:$mimeType;base64,$base64Image'},
      );

      return Result.success(JobResponse.fromJson(response.data!));
    } on DioException catch (e) {
      return Result.failure(_extractError(e), e);
    } catch (e) {
      return Result.failure(e.toString(), e);
    }
  }

  Future<Result<JobResponse>> getJobStatus(String jobId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/api/jobs/$jobId',
      );

      return Result.success(JobResponse.fromJson(response.data!));
    } on DioException catch (e) {
      return Result.failure(_extractError(e), e);
    } catch (e) {
      return Result.failure(e.toString(), e);
    }
  }

  Future<Result<JobResponse>> pollUntilComplete(
    String jobId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
    void Function(JobResponse)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final result = await getJobStatus(jobId);

      switch (result) {
        case Success(data: final job):
          onProgress?.call(job);
          if (job.isFinished) {
            return Result.success(job);
          }
        case Failure(message: final msg, error: final err):
          return Result.failure(msg, err);
      }

      await Future.delayed(interval);
    }

    return Result.failure('Job timed out after ${timeout.inMinutes} minutes');
  }

  Future<Result<void>> cancelJob(String jobId) async {
    try {
      await _dio.delete('$_baseUrl/api/jobs/$jobId');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(_extractError(e), e);
    } catch (e) {
      return Result.failure(e.toString(), e);
    }
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/png',
    };
  }

  String _extractError(DioException e) {
    if (e.response?.data case {'error': final String error}) {
      return error;
    }
    return e.message ?? 'Network error';
  }
}

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 2),
    ),
  );
});

final layerServiceProvider = Provider<LayerService>((ref) {
  final dio = ref.watch(dioProvider);
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  return LayerService(dio: dio, baseUrl: baseUrl);
});
