import 'package:json_annotation/json_annotation.dart';

part 'job.g.dart';

enum JobStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class LayerResult {
  final String id;
  final String url;
  final int width;
  final int height;
  final int order;

  const LayerResult({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    required this.order,
  });

  factory LayerResult.fromJson(Map<String, dynamic> json) =>
      _$LayerResultFromJson(json);
  Map<String, dynamic> toJson() => _$LayerResultToJson(this);
}

@JsonSerializable()
class Job {
  final String id;
  final JobStatus status;
  final String imageUrl;
  final String? falRequestId;
  final double progress;
  final List<LayerResult>? layers;
  final String? error;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Job({
    required this.id,
    required this.status,
    required this.imageUrl,
    this.falRequestId,
    this.progress = 0.0,
    this.layers,
    this.error,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
  Map<String, dynamic> toJson() => _$JobToJson(this);

  Job copyWith({
    String? id,
    JobStatus? status,
    String? imageUrl,
    String? falRequestId,
    double? progress,
    List<LayerResult>? layers,
    String? error,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Job(
      id: id ?? this.id,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      falRequestId: falRequestId ?? this.falRequestId,
      progress: progress ?? this.progress,
      layers: layers ?? this.layers,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
