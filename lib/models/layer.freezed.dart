// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LayerTransform _$LayerTransformFromJson(Map<String, dynamic> json) {
  return _LayerTransform.fromJson(json);
}

/// @nodoc
mixin _$LayerTransform {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get scale => throw _privateConstructorUsedError;
  double get rotation => throw _privateConstructorUsedError;
  double get opacity => throw _privateConstructorUsedError;

  /// Serializes this LayerTransform to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LayerTransform
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LayerTransformCopyWith<LayerTransform> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayerTransformCopyWith<$Res> {
  factory $LayerTransformCopyWith(
    LayerTransform value,
    $Res Function(LayerTransform) then,
  ) = _$LayerTransformCopyWithImpl<$Res, LayerTransform>;
  @useResult
  $Res call({
    double x,
    double y,
    double scale,
    double rotation,
    double opacity,
  });
}

/// @nodoc
class _$LayerTransformCopyWithImpl<$Res, $Val extends LayerTransform>
    implements $LayerTransformCopyWith<$Res> {
  _$LayerTransformCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LayerTransform
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? scale = null,
    Object? rotation = null,
    Object? opacity = null,
  }) {
    return _then(
      _value.copyWith(
            x: null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double,
            y: null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double,
            scale: null == scale
                ? _value.scale
                : scale // ignore: cast_nullable_to_non_nullable
                      as double,
            rotation: null == rotation
                ? _value.rotation
                : rotation // ignore: cast_nullable_to_non_nullable
                      as double,
            opacity: null == opacity
                ? _value.opacity
                : opacity // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LayerTransformImplCopyWith<$Res>
    implements $LayerTransformCopyWith<$Res> {
  factory _$$LayerTransformImplCopyWith(
    _$LayerTransformImpl value,
    $Res Function(_$LayerTransformImpl) then,
  ) = __$$LayerTransformImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double x,
    double y,
    double scale,
    double rotation,
    double opacity,
  });
}

/// @nodoc
class __$$LayerTransformImplCopyWithImpl<$Res>
    extends _$LayerTransformCopyWithImpl<$Res, _$LayerTransformImpl>
    implements _$$LayerTransformImplCopyWith<$Res> {
  __$$LayerTransformImplCopyWithImpl(
    _$LayerTransformImpl _value,
    $Res Function(_$LayerTransformImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LayerTransform
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? scale = null,
    Object? rotation = null,
    Object? opacity = null,
  }) {
    return _then(
      _$LayerTransformImpl(
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        scale: null == scale
            ? _value.scale
            : scale // ignore: cast_nullable_to_non_nullable
                  as double,
        rotation: null == rotation
            ? _value.rotation
            : rotation // ignore: cast_nullable_to_non_nullable
                  as double,
        opacity: null == opacity
            ? _value.opacity
            : opacity // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LayerTransformImpl implements _LayerTransform {
  const _$LayerTransformImpl({
    this.x = 0.0,
    this.y = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });

  factory _$LayerTransformImpl.fromJson(Map<String, dynamic> json) =>
      _$$LayerTransformImplFromJson(json);

  @override
  @JsonKey()
  final double x;
  @override
  @JsonKey()
  final double y;
  @override
  @JsonKey()
  final double scale;
  @override
  @JsonKey()
  final double rotation;
  @override
  @JsonKey()
  final double opacity;

  @override
  String toString() {
    return 'LayerTransform(x: $x, y: $y, scale: $scale, rotation: $rotation, opacity: $opacity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LayerTransformImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation) &&
            (identical(other.opacity, opacity) || other.opacity == opacity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, scale, rotation, opacity);

  /// Create a copy of LayerTransform
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LayerTransformImplCopyWith<_$LayerTransformImpl> get copyWith =>
      __$$LayerTransformImplCopyWithImpl<_$LayerTransformImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LayerTransformImplToJson(this);
  }
}

abstract class _LayerTransform implements LayerTransform {
  const factory _LayerTransform({
    final double x,
    final double y,
    final double scale,
    final double rotation,
    final double opacity,
  }) = _$LayerTransformImpl;

  factory _LayerTransform.fromJson(Map<String, dynamic> json) =
      _$LayerTransformImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get scale;
  @override
  double get rotation;
  @override
  double get opacity;

  /// Create a copy of LayerTransform
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LayerTransformImplCopyWith<_$LayerTransformImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LayerBbox _$LayerBboxFromJson(Map<String, dynamic> json) {
  return _LayerBbox.fromJson(json);
}

/// @nodoc
mixin _$LayerBbox {
  double get left => throw _privateConstructorUsedError;
  double get top => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;

  /// Serializes this LayerBbox to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LayerBbox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LayerBboxCopyWith<LayerBbox> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayerBboxCopyWith<$Res> {
  factory $LayerBboxCopyWith(LayerBbox value, $Res Function(LayerBbox) then) =
      _$LayerBboxCopyWithImpl<$Res, LayerBbox>;
  @useResult
  $Res call({double left, double top, double width, double height});
}

/// @nodoc
class _$LayerBboxCopyWithImpl<$Res, $Val extends LayerBbox>
    implements $LayerBboxCopyWith<$Res> {
  _$LayerBboxCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LayerBbox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? left = null,
    Object? top = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(
      _value.copyWith(
            left: null == left
                ? _value.left
                : left // ignore: cast_nullable_to_non_nullable
                      as double,
            top: null == top
                ? _value.top
                : top // ignore: cast_nullable_to_non_nullable
                      as double,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as double,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LayerBboxImplCopyWith<$Res>
    implements $LayerBboxCopyWith<$Res> {
  factory _$$LayerBboxImplCopyWith(
    _$LayerBboxImpl value,
    $Res Function(_$LayerBboxImpl) then,
  ) = __$$LayerBboxImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double left, double top, double width, double height});
}

/// @nodoc
class __$$LayerBboxImplCopyWithImpl<$Res>
    extends _$LayerBboxCopyWithImpl<$Res, _$LayerBboxImpl>
    implements _$$LayerBboxImplCopyWith<$Res> {
  __$$LayerBboxImplCopyWithImpl(
    _$LayerBboxImpl _value,
    $Res Function(_$LayerBboxImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LayerBbox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? left = null,
    Object? top = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(
      _$LayerBboxImpl(
        left: null == left
            ? _value.left
            : left // ignore: cast_nullable_to_non_nullable
                  as double,
        top: null == top
            ? _value.top
            : top // ignore: cast_nullable_to_non_nullable
                  as double,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as double,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LayerBboxImpl implements _LayerBbox {
  const _$LayerBboxImpl({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory _$LayerBboxImpl.fromJson(Map<String, dynamic> json) =>
      _$$LayerBboxImplFromJson(json);

  @override
  final double left;
  @override
  final double top;
  @override
  final double width;
  @override
  final double height;

  @override
  String toString() {
    return 'LayerBbox(left: $left, top: $top, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LayerBboxImpl &&
            (identical(other.left, left) || other.left == left) &&
            (identical(other.top, top) || other.top == top) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, left, top, width, height);

  /// Create a copy of LayerBbox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LayerBboxImplCopyWith<_$LayerBboxImpl> get copyWith =>
      __$$LayerBboxImplCopyWithImpl<_$LayerBboxImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LayerBboxImplToJson(this);
  }
}

abstract class _LayerBbox implements LayerBbox {
  const factory _LayerBbox({
    required final double left,
    required final double top,
    required final double width,
    required final double height,
  }) = _$LayerBboxImpl;

  factory _LayerBbox.fromJson(Map<String, dynamic> json) =
      _$LayerBboxImpl.fromJson;

  @override
  double get left;
  @override
  double get top;
  @override
  double get width;
  @override
  double get height;

  /// Create a copy of LayerBbox
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LayerBboxImplCopyWith<_$LayerBboxImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Layer _$LayerFromJson(Map<String, dynamic> json) {
  return _Layer.fromJson(json);
}

/// @nodoc
mixin _$Layer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get pngUrl => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  LayerBbox? get bbox => throw _privateConstructorUsedError;
  LayerTransform get transform => throw _privateConstructorUsedError;
  int get zIndex => throw _privateConstructorUsedError;
  bool get visible => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Layer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Layer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LayerCopyWith<Layer> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayerCopyWith<$Res> {
  factory $LayerCopyWith(Layer value, $Res Function(Layer) then) =
      _$LayerCopyWithImpl<$Res, Layer>;
  @useResult
  $Res call({
    String id,
    String name,
    String pngUrl,
    int width,
    int height,
    LayerBbox? bbox,
    LayerTransform transform,
    int zIndex,
    bool visible,
    Map<String, dynamic>? metadata,
  });

  $LayerBboxCopyWith<$Res>? get bbox;
  $LayerTransformCopyWith<$Res> get transform;
}

/// @nodoc
class _$LayerCopyWithImpl<$Res, $Val extends Layer>
    implements $LayerCopyWith<$Res> {
  _$LayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Layer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? pngUrl = null,
    Object? width = null,
    Object? height = null,
    Object? bbox = freezed,
    Object? transform = null,
    Object? zIndex = null,
    Object? visible = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            pngUrl: null == pngUrl
                ? _value.pngUrl
                : pngUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int,
            bbox: freezed == bbox
                ? _value.bbox
                : bbox // ignore: cast_nullable_to_non_nullable
                      as LayerBbox?,
            transform: null == transform
                ? _value.transform
                : transform // ignore: cast_nullable_to_non_nullable
                      as LayerTransform,
            zIndex: null == zIndex
                ? _value.zIndex
                : zIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as bool,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of Layer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayerBboxCopyWith<$Res>? get bbox {
    if (_value.bbox == null) {
      return null;
    }

    return $LayerBboxCopyWith<$Res>(_value.bbox!, (value) {
      return _then(_value.copyWith(bbox: value) as $Val);
    });
  }

  /// Create a copy of Layer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayerTransformCopyWith<$Res> get transform {
    return $LayerTransformCopyWith<$Res>(_value.transform, (value) {
      return _then(_value.copyWith(transform: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LayerImplCopyWith<$Res> implements $LayerCopyWith<$Res> {
  factory _$$LayerImplCopyWith(
    _$LayerImpl value,
    $Res Function(_$LayerImpl) then,
  ) = __$$LayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String pngUrl,
    int width,
    int height,
    LayerBbox? bbox,
    LayerTransform transform,
    int zIndex,
    bool visible,
    Map<String, dynamic>? metadata,
  });

  @override
  $LayerBboxCopyWith<$Res>? get bbox;
  @override
  $LayerTransformCopyWith<$Res> get transform;
}

/// @nodoc
class __$$LayerImplCopyWithImpl<$Res>
    extends _$LayerCopyWithImpl<$Res, _$LayerImpl>
    implements _$$LayerImplCopyWith<$Res> {
  __$$LayerImplCopyWithImpl(
    _$LayerImpl _value,
    $Res Function(_$LayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Layer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? pngUrl = null,
    Object? width = null,
    Object? height = null,
    Object? bbox = freezed,
    Object? transform = null,
    Object? zIndex = null,
    Object? visible = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$LayerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        pngUrl: null == pngUrl
            ? _value.pngUrl
            : pngUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int,
        bbox: freezed == bbox
            ? _value.bbox
            : bbox // ignore: cast_nullable_to_non_nullable
                  as LayerBbox?,
        transform: null == transform
            ? _value.transform
            : transform // ignore: cast_nullable_to_non_nullable
                  as LayerTransform,
        zIndex: null == zIndex
            ? _value.zIndex
            : zIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        visible: null == visible
            ? _value.visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as bool,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LayerImpl implements _Layer {
  const _$LayerImpl({
    required this.id,
    required this.name,
    required this.pngUrl,
    required this.width,
    required this.height,
    this.bbox,
    this.transform = const LayerTransform(),
    this.zIndex = 0,
    this.visible = true,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$LayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$LayerImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String pngUrl;
  @override
  final int width;
  @override
  final int height;
  @override
  final LayerBbox? bbox;
  @override
  @JsonKey()
  final LayerTransform transform;
  @override
  @JsonKey()
  final int zIndex;
  @override
  @JsonKey()
  final bool visible;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Layer(id: $id, name: $name, pngUrl: $pngUrl, width: $width, height: $height, bbox: $bbox, transform: $transform, zIndex: $zIndex, visible: $visible, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.pngUrl, pngUrl) || other.pngUrl == pngUrl) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.bbox, bbox) || other.bbox == bbox) &&
            (identical(other.transform, transform) ||
                other.transform == transform) &&
            (identical(other.zIndex, zIndex) || other.zIndex == zIndex) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    pngUrl,
    width,
    height,
    bbox,
    transform,
    zIndex,
    visible,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of Layer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LayerImplCopyWith<_$LayerImpl> get copyWith =>
      __$$LayerImplCopyWithImpl<_$LayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LayerImplToJson(this);
  }
}

abstract class _Layer implements Layer {
  const factory _Layer({
    required final String id,
    required final String name,
    required final String pngUrl,
    required final int width,
    required final int height,
    final LayerBbox? bbox,
    final LayerTransform transform,
    final int zIndex,
    final bool visible,
    final Map<String, dynamic>? metadata,
  }) = _$LayerImpl;

  factory _Layer.fromJson(Map<String, dynamic> json) = _$LayerImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get pngUrl;
  @override
  int get width;
  @override
  int get height;
  @override
  LayerBbox? get bbox;
  @override
  LayerTransform get transform;
  @override
  int get zIndex;
  @override
  bool get visible;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Layer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LayerImplCopyWith<_$LayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
