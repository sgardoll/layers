import 'package:flutter/foundation.dart';

@immutable
class LayerTransform {
  const LayerTransform({
    this.x = 0.0,
    this.y = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });

  final double x;
  final double y;
  final double scale;
  final double rotation;
  final double opacity;

  LayerTransform copyWith({
    double? x,
    double? y,
    double? scale,
    double? rotation,
    double? opacity,
  }) {
    return LayerTransform(
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
    );
  }

  static LayerTransform fromJson(Map<String, dynamic> json) => LayerTransform(
        x: (json['x'] as num?)?.toDouble() ?? 0.0,
        y: (json['y'] as num?)?.toDouble() ?? 0.0,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'x': x,
        'y': y,
        'scale': scale,
        'rotation': rotation,
        'opacity': opacity,
      };
}

@immutable
class LayerBbox {
  const LayerBbox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  LayerBbox copyWith({
    double? left,
    double? top,
    double? width,
    double? height,
  }) {
    return LayerBbox(
      left: left ?? this.left,
      top: top ?? this.top,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  static LayerBbox fromJson(Map<String, dynamic> json) => LayerBbox(
        left: (json['left'] as num).toDouble(),
        top: (json['top'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      };
}

@immutable
class Layer {
  const Layer({
    required this.id,
    required this.name,
    required this.pngUrl,
    required this.width,
    required this.height,
    this.bbox,
    this.transform = const LayerTransform(),
    this.zIndex = 0,
    this.visible = true,
    this.metadata,
  });

  final String id;
  final String name;
  final String pngUrl;
  final int width;
  final int height;
  final LayerBbox? bbox;
  final LayerTransform transform;
  final int zIndex;
  final bool visible;
  final Map<String, dynamic>? metadata;

  Layer copyWith({
    String? id,
    String? name,
    String? pngUrl,
    int? width,
    int? height,
    LayerBbox? bbox,
    LayerTransform? transform,
    int? zIndex,
    bool? visible,
    Map<String, dynamic>? metadata,
  }) {
    return Layer(
      id: id ?? this.id,
      name: name ?? this.name,
      pngUrl: pngUrl ?? this.pngUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      bbox: bbox ?? this.bbox,
      transform: transform ?? this.transform,
      zIndex: zIndex ?? this.zIndex,
      visible: visible ?? this.visible,
      metadata: metadata ?? this.metadata,
    );
  }

  static Layer fromJson(Map<String, dynamic> json) => Layer(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        pngUrl: (json['pngUrl'] ?? '').toString(),
        width: (json['width'] as num?)?.toInt() ?? 0,
        height: (json['height'] as num?)?.toInt() ?? 0,
        bbox: json['bbox'] is Map
            ? LayerBbox.fromJson(Map<String, dynamic>.from(json['bbox'] as Map))
            : null,
        transform: json['transform'] is Map
            ? LayerTransform.fromJson(
                Map<String, dynamic>.from(json['transform'] as Map),
              )
            : const LayerTransform(),
        zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
        visible: json['visible'] as bool? ?? true,
        metadata: json['metadata'] is Map
            ? Map<String, dynamic>.from(json['metadata'] as Map)
            : null,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'pngUrl': pngUrl,
        'width': width,
        'height': height,
        'bbox': bbox?.toJson(),
        'transform': transform.toJson(),
        'zIndex': zIndex,
        'visible': visible,
        'metadata': metadata,
      };
}
