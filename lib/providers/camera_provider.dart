import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_provider.freezed.dart';

@freezed
class CameraState with _$CameraState {
  const factory CameraState({
    @Default(0.0) double rotationX,
    @Default(0.0) double rotationY,
    @Default(1.0) double zoom,
    @Default(0.0) double panX,
    @Default(0.0) double panY,
    @Default(80.0) double layerSpacing,
    @Default(false) bool isAnimating,
  }) = _CameraState;

  const CameraState._();

  static const double minZoom = 0.5;
  static const double maxZoom = 3.0;
  static const double minRotationX = -math.pi / 3;
  static const double maxRotationX = math.pi / 3;
  static const double defaultLayerSpacing = 80.0;
}

class CameraNotifier extends Notifier<CameraState> {
  @override
  CameraState build() => const CameraState();

  void rotate(double deltaX, double deltaY) {
    final newRotationX = (state.rotationX + deltaY * 0.01).clamp(
      CameraState.minRotationX,
      CameraState.maxRotationX,
    );
    final newRotationY = state.rotationY + deltaX * 0.01;

    state = state.copyWith(rotationX: newRotationX, rotationY: newRotationY);
  }

  void pan(double deltaX, double deltaY) {
    state = state.copyWith(
      panX: state.panX + deltaX,
      panY: state.panY + deltaY,
    );
  }

  void setZoom(double zoom) {
    state = state.copyWith(
      zoom: zoom.clamp(CameraState.minZoom, CameraState.maxZoom),
    );
  }

  void zoomBy(double factor) {
    setZoom(state.zoom * factor);
  }

  void setLayerSpacing(double spacing) {
    state = state.copyWith(layerSpacing: spacing.clamp(20.0, 200.0));
  }

  void reset() {
    state = const CameraState();
  }

  void setPreset(CameraPreset preset) {
    switch (preset) {
      case CameraPreset.front:
        state = const CameraState(rotationX: 0, rotationY: 0);
      case CameraPreset.top:
        state = const CameraState(rotationX: -math.pi / 4, rotationY: 0);
      case CameraPreset.side:
        state = const CameraState(rotationX: 0, rotationY: math.pi / 4);
      case CameraPreset.perspective:
        state = const CameraState(rotationX: -0.3, rotationY: 0.5);
    }
  }
}

enum CameraPreset { front, top, side, perspective }

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(
  CameraNotifier.new,
);
