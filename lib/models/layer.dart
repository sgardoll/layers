import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer.freezed.dart';
part 'layer.g.dart';

@freezed
class LayerTransform with _$LayerTransform {
  const factory LayerTransform({
    @Default(0.0) double x,
    @Default(0.0) double y,
    @Default(1.0) double scale,
    @Default(0.0) double rotation,
    @Default(1.0) double opacity,
  }) = _LayerTransform;

  factory LayerTransform.fromJson(Map<String, dynamic> json) =>
      _$LayerTransformFromJson(json);
}

@freezed
class LayerBbox with _$LayerBbox {
  const factory LayerBbox({
    required double left,
    required double top,
    required double width,
    required double height,
  }) = _LayerBbox;

  factory LayerBbox.fromJson(Map<String, dynamic> json) =>
      _$LayerBboxFromJson(json);
}

@freezed
class Layer with _$Layer {
  const factory Layer({
    required String id,
    required String name,
    required String pngUrl,
    required int width,
    required int height,
    LayerBbox? bbox,
    @Default(LayerTransform()) LayerTransform transform,
    @Default(0) int zIndex,
    @Default(true) bool visible,
    Map<String, dynamic>? metadata,
  }) = _Layer;

  factory Layer.fromJson(Map<String, dynamic> json) => _$LayerFromJson(json);
}
