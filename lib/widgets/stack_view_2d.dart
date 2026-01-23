import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/layer.dart';
import '../providers/layer_provider.dart';

class StackView2D extends ConsumerStatefulWidget {
  const StackView2D({super.key});

  @override
  ConsumerState<StackView2D> createState() => _StackView2DState();
}

class _StackView2DState extends ConsumerState<StackView2D> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleLayers = ref.watch(visibleLayersProvider);
    final selectedId = ref.watch(layerProvider).selectedLayerId;

    if (visibleLayers.isEmpty) {
      return _buildEmptyState();
    }

    final sortedLayers = [...visibleLayers]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Container(
      color: const Color(0xFF1a1a2e),
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 0.1,
        maxScale: 5.0,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCheckerboard(),
                ...sortedLayers.map(
                  (layer) => _buildLayerImage(
                    layer,
                    isSelected: layer.id == selectedId,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No visible layers',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckerboard() {
    return CustomPaint(painter: _CheckerboardPainter());
  }

  Widget _buildLayerImage(Layer layer, {required bool isSelected}) {
    return GestureDetector(
      onTap: () => ref.read(layerProvider.notifier).selectLayer(layer.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: const Color(0xFF6366f1), width: 2)
              : null,
        ),
        child: CachedNetworkImage(
          imageUrl: layer.pngUrl,
          fit: BoxFit.contain,
          placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white24),
          ),
        ),
      ),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 20.0;
    final lightPaint = Paint()..color = const Color(0xFF2a2a3e);
    final darkPaint = Paint()..color = const Color(0xFF1a1a2e);

    for (var y = 0.0; y < size.height; y += squareSize) {
      for (var x = 0.0; x < size.width; x += squareSize) {
        final isLight = ((x ~/ squareSize) + (y ~/ squareSize)) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isLight ? lightPaint : darkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
