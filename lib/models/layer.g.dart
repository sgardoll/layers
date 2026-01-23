// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LayerTransformImpl _$$LayerTransformImplFromJson(Map<String, dynamic> json) =>
    _$LayerTransformImpl(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$LayerTransformImplToJson(
  _$LayerTransformImpl instance,
) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
  'scale': instance.scale,
  'rotation': instance.rotation,
  'opacity': instance.opacity,
};

_$LayerBboxImpl _$$LayerBboxImplFromJson(Map<String, dynamic> json) =>
    _$LayerBboxImpl(
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$$LayerBboxImplToJson(_$LayerBboxImpl instance) =>
    <String, dynamic>{
      'left': instance.left,
      'top': instance.top,
      'width': instance.width,
      'height': instance.height,
    };

_$LayerImpl _$$LayerImplFromJson(Map<String, dynamic> json) => _$LayerImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  pngUrl: json['pngUrl'] as String,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  bbox: json['bbox'] == null
      ? null
      : LayerBbox.fromJson(json['bbox'] as Map<String, dynamic>),
  transform: json['transform'] == null
      ? const LayerTransform()
      : LayerTransform.fromJson(json['transform'] as Map<String, dynamic>),
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  visible: json['visible'] as bool? ?? true,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$LayerImplToJson(_$LayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'pngUrl': instance.pngUrl,
      'width': instance.width,
      'height': instance.height,
      'bbox': instance.bbox,
      'transform': instance.transform,
      'zIndex': instance.zIndex,
      'visible': instance.visible,
      'metadata': instance.metadata,
    };
