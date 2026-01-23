import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/layer.dart';

class LayerCard3D extends StatelessWidget {
  final Layer layer;
  final int index;
  final int totalLayers;
  final double spacing;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const LayerCard3D({
    super.key,
    required this.layer,
    required this.index,
    required this.totalLayers,
    required this.spacing,
    this.isSelected = false,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final zOffset = (index - totalLayers / 2) * spacing;

    return Transform(
      transform: Matrix4.identity()..translate(0.0, 0.0, zOffset),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: const Color(0xFF6366f1), width: 3)
                : null,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.4 : 0.2),
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: layer.pngUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                if (!layer.visible)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(
                        child: Icon(
                          Icons.visibility_off,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      layer.name ?? 'Layer ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: index * 50),
          duration: const Duration(milliseconds: 300),
        ),
        SlideEffect(
          begin: const Offset(0, 0.1),
          delay: Duration(milliseconds: index * 50),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      ],
    );
  }
}
