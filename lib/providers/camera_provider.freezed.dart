// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CameraState {
  double get rotationX => throw _privateConstructorUsedError;
  double get rotationY => throw _privateConstructorUsedError;
  double get zoom => throw _privateConstructorUsedError;
  double get panX => throw _privateConstructorUsedError;
  double get panY => throw _privateConstructorUsedError;
  double get layerSpacing => throw _privateConstructorUsedError;
  bool get isAnimating => throw _privateConstructorUsedError;

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CameraStateCopyWith<CameraState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraStateCopyWith<$Res> {
  factory $CameraStateCopyWith(
    CameraState value,
    $Res Function(CameraState) then,
  ) = _$CameraStateCopyWithImpl<$Res, CameraState>;
  @useResult
  $Res call({
    double rotationX,
    double rotationY,
    double zoom,
    double panX,
    double panY,
    double layerSpacing,
    bool isAnimating,
  });
}

/// @nodoc
class _$CameraStateCopyWithImpl<$Res, $Val extends CameraState>
    implements $CameraStateCopyWith<$Res> {
  _$CameraStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rotationX = null,
    Object? rotationY = null,
    Object? zoom = null,
    Object? panX = null,
    Object? panY = null,
    Object? layerSpacing = null,
    Object? isAnimating = null,
  }) {
    return _then(
      _value.copyWith(
            rotationX: null == rotationX
                ? _value.rotationX
                : rotationX // ignore: cast_nullable_to_non_nullable
                      as double,
            rotationY: null == rotationY
                ? _value.rotationY
                : rotationY // ignore: cast_nullable_to_non_nullable
                      as double,
            zoom: null == zoom
                ? _value.zoom
                : zoom // ignore: cast_nullable_to_non_nullable
                      as double,
            panX: null == panX
                ? _value.panX
                : panX // ignore: cast_nullable_to_non_nullable
                      as double,
            panY: null == panY
                ? _value.panY
                : panY // ignore: cast_nullable_to_non_nullable
                      as double,
            layerSpacing: null == layerSpacing
                ? _value.layerSpacing
                : layerSpacing // ignore: cast_nullable_to_non_nullable
                      as double,
            isAnimating: null == isAnimating
                ? _value.isAnimating
                : isAnimating // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CameraStateImplCopyWith<$Res>
    implements $CameraStateCopyWith<$Res> {
  factory _$$CameraStateImplCopyWith(
    _$CameraStateImpl value,
    $Res Function(_$CameraStateImpl) then,
  ) = __$$CameraStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double rotationX,
    double rotationY,
    double zoom,
    double panX,
    double panY,
    double layerSpacing,
    bool isAnimating,
  });
}

/// @nodoc
class __$$CameraStateImplCopyWithImpl<$Res>
    extends _$CameraStateCopyWithImpl<$Res, _$CameraStateImpl>
    implements _$$CameraStateImplCopyWith<$Res> {
  __$$CameraStateImplCopyWithImpl(
    _$CameraStateImpl _value,
    $Res Function(_$CameraStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rotationX = null,
    Object? rotationY = null,
    Object? zoom = null,
    Object? panX = null,
    Object? panY = null,
    Object? layerSpacing = null,
    Object? isAnimating = null,
  }) {
    return _then(
      _$CameraStateImpl(
        rotationX: null == rotationX
            ? _value.rotationX
            : rotationX // ignore: cast_nullable_to_non_nullable
                  as double,
        rotationY: null == rotationY
            ? _value.rotationY
            : rotationY // ignore: cast_nullable_to_non_nullable
                  as double,
        zoom: null == zoom
            ? _value.zoom
            : zoom // ignore: cast_nullable_to_non_nullable
                  as double,
        panX: null == panX
            ? _value.panX
            : panX // ignore: cast_nullable_to_non_nullable
                  as double,
        panY: null == panY
            ? _value.panY
            : panY // ignore: cast_nullable_to_non_nullable
                  as double,
        layerSpacing: null == layerSpacing
            ? _value.layerSpacing
            : layerSpacing // ignore: cast_nullable_to_non_nullable
                  as double,
        isAnimating: null == isAnimating
            ? _value.isAnimating
            : isAnimating // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CameraStateImpl extends _CameraState with DiagnosticableTreeMixin {
  const _$CameraStateImpl({
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.zoom = 1.0,
    this.panX = 0.0,
    this.panY = 0.0,
    this.layerSpacing = 80.0,
    this.isAnimating = false,
  }) : super._();

  @override
  @JsonKey()
  final double rotationX;
  @override
  @JsonKey()
  final double rotationY;
  @override
  @JsonKey()
  final double zoom;
  @override
  @JsonKey()
  final double panX;
  @override
  @JsonKey()
  final double panY;
  @override
  @JsonKey()
  final double layerSpacing;
  @override
  @JsonKey()
  final bool isAnimating;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CameraState(rotationX: $rotationX, rotationY: $rotationY, zoom: $zoom, panX: $panX, panY: $panY, layerSpacing: $layerSpacing, isAnimating: $isAnimating)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CameraState'))
      ..add(DiagnosticsProperty('rotationX', rotationX))
      ..add(DiagnosticsProperty('rotationY', rotationY))
      ..add(DiagnosticsProperty('zoom', zoom))
      ..add(DiagnosticsProperty('panX', panX))
      ..add(DiagnosticsProperty('panY', panY))
      ..add(DiagnosticsProperty('layerSpacing', layerSpacing))
      ..add(DiagnosticsProperty('isAnimating', isAnimating));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraStateImpl &&
            (identical(other.rotationX, rotationX) ||
                other.rotationX == rotationX) &&
            (identical(other.rotationY, rotationY) ||
                other.rotationY == rotationY) &&
            (identical(other.zoom, zoom) || other.zoom == zoom) &&
            (identical(other.panX, panX) || other.panX == panX) &&
            (identical(other.panY, panY) || other.panY == panY) &&
            (identical(other.layerSpacing, layerSpacing) ||
                other.layerSpacing == layerSpacing) &&
            (identical(other.isAnimating, isAnimating) ||
                other.isAnimating == isAnimating));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    rotationX,
    rotationY,
    zoom,
    panX,
    panY,
    layerSpacing,
    isAnimating,
  );

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraStateImplCopyWith<_$CameraStateImpl> get copyWith =>
      __$$CameraStateImplCopyWithImpl<_$CameraStateImpl>(this, _$identity);
}

abstract class _CameraState extends CameraState {
  const factory _CameraState({
    final double rotationX,
    final double rotationY,
    final double zoom,
    final double panX,
    final double panY,
    final double layerSpacing,
    final bool isAnimating,
  }) = _$CameraStateImpl;
  const _CameraState._() : super._();

  @override
  double get rotationX;
  @override
  double get rotationY;
  @override
  double get zoom;
  @override
  double get panX;
  @override
  double get panY;
  @override
  double get layerSpacing;
  @override
  bool get isAnimating;

  /// Create a copy of CameraState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CameraStateImplCopyWith<_$CameraStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
