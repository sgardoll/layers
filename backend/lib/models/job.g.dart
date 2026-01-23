// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LayerResult _$LayerResultFromJson(Map<String, dynamic> json) => LayerResult(
      id: json['id'] as String,
      url: json['url'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$LayerResultToJson(LayerResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
      'order': instance.order,
    };

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      id: json['id'] as String,
      status: $enumDecode(_$JobStatusEnumMap, json['status']),
      imageUrl: json['imageUrl'] as String,
      falRequestId: json['falRequestId'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      layers: (json['layers'] as List<dynamic>?)
          ?.map((e) => LayerResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'id': instance.id,
      'status': _$JobStatusEnumMap[instance.status]!,
      'imageUrl': instance.imageUrl,
      'falRequestId': instance.falRequestId,
      'progress': instance.progress,
      'layers': instance.layers,
      'error': instance.error,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

const _$JobStatusEnumMap = {
  JobStatus.pending: 'pending',
  JobStatus.processing: 'processing',
  JobStatus.completed: 'completed',
  JobStatus.failed: 'failed',
  JobStatus.cancelled: 'cancelled',
};
