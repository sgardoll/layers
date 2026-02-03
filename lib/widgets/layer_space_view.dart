import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layer.dart';
import '../providers/camera_provider.dart';
import 'layer_card_3d.dart';

class LayerSpaceView extends ConsumerStatefulWidget {
  final List<Layer> layers;
  final String? selectedLayerId;
  final ValueChanged<String>? onLayerSelected;
  final ValueChanged<String>? onLayerDoubleTap;

  const LayerSpaceView({
    super.key,
    required this.layers,
    this.selectedLayerId,
    this.onLayerSelected,
    this.onLayerDoubleTap,
  });

  @override
  ConsumerState<LayerSpaceView> createState() => _LayerSpaceViewState();
}

class _LayerSpaceViewState extends ConsumerState<LayerSpaceView> {
  Offset? _lastFocalPoint;
  double? _lastScale;
  bool _isPanning = false;

  @override
  Widget build(BuildContext context) {
    final camera = ref.watch(cameraProvider);
    final cameraNotifier = ref.read(cameraProvider.notifier);

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final zoomDelta = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
          cameraNotifier.zoomBy(zoomDelta);
        }
      },
      child: GestureDetector(
        onScaleStart: (details) {
          _lastFocalPoint = details.focalPoint;
          _lastScale = camera.zoom;
          _isPanning = details.pointerCount == 1;
        },
        onScaleUpdate: (details) {
          if (_lastFocalPoint == null) return;

          final delta = details.focalPoint - _lastFocalPoint!;

          if (details.pointerCount == 2) {
            cameraNotifier.setZoom(_lastScale! * details.scale);
            cameraNotifier.rotate(delta.dx, delta.dy);
          } else if (_isPanning) {
            final isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed
                .any(
                  (key) =>
                      key == LogicalKeyboardKey.shiftLeft ||
                      key == LogicalKeyboardKey.shiftRight,
                );

            if (isShiftPressed) {
              cameraNotifier.pan(delta.dx, delta.dy);
            } else {
              cameraNotifier.rotate(delta.dx, delta.dy);
            }
          }
        },
        onScaleEnd: (_) {
          _lastFocalPoint = null;
          _lastScale = null;
          _isPanning = false;
        },
        child: Container(
          color: const Color(0xFF1a1a2e),
          child: Center(
            // Apply camera transform first (rotate/zoom)
            child: Transform(
              transform: _buildCameraMatrix(camera),
              alignment: Alignment.center,
              child: Transform.scale(
                scale: camera.zoom,
                child: _buildLayerStackWithZOffset(camera),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Matrix4 _buildCameraMatrix(CameraState camera) {
    return Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(camera.rotationX)
      ..rotateY(camera.rotationY);
  }

  Widget _buildLayerStackWithZOffset(CameraState camera) {
    // Build layer stack with proper Z-translation at camera transform level
    // This ensures layer depth is consistent between list panel and 3D canvas
    if (widget.layers.isEmpty) {
      return const Center(
        child: Text(
          'No layers',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    // Sort by zIndex ascending so back layers are painted first in Stack
    // (Stack paints children in order: first child painted first, last child painted last)
    // Filter out hidden layers - they should not appear in 3D view
    final sortedLayers =
        [...widget.layers].where((layer) => layer.visible).toList()
          ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return SizedBox(
      width: 400,
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < sortedLayers.length; i++)
            SizedBox(
              width: 400,
              height: 400,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(
                    camera.panX,
                    camera.panY,
                    (sortedLayers[i].zIndex - sortedLayers.length / 2) *
                        camera.layerSpacing,
                  ),
                alignment: Alignment.center,
                child: LayerCard3D(
                  layer: sortedLayers[i],
                  index: i,
                  totalLayers: sortedLayers.length,
                  spacing: camera.layerSpacing,
                  isSelected: sortedLayers[i].id == widget.selectedLayerId,
                  onTap: () => widget.onLayerSelected?.call(sortedLayers[i].id),
                  onDoubleTap: () =>
                      widget.onLayerDoubleTap?.call(sortedLayers[i].id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
