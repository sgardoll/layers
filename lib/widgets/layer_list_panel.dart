import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layer.dart';
import '../providers/layer_provider.dart';

class LayerListPanel extends ConsumerWidget {
  final double width;

  const LayerListPanel({super.key, this.width = 280});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layerState = ref.watch(layerProvider);
    final layerNotifier = ref.read(layerProvider.notifier);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: layerState.layers.isEmpty
                ? _buildEmptyState()
                : _buildLayerList(layerState, layerNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Layers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(layerProvider).layers.length;
              return Text(
                '$count',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined, color: Colors.white24, size: 48),
          SizedBox(height: 16),
          Text(
            'No layers yet',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'Import an image to get started',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerList(LayerState layerState, LayerNotifier notifier) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: layerState.layers.length,
      onReorder: notifier.reorderLayers,
      itemBuilder: (context, index) {
        final layer = layerState.layers[index];
        final isSelected = layer.id == layerState.selectedLayerId;

        return _LayerListItem(
          key: ValueKey(layer.id),
          layer: layer,
          isSelected: isSelected,
          onTap: () => notifier.selectLayer(layer.id),
          onVisibilityToggle: () => notifier.toggleVisibility(layer.id),
          onDelete: () => notifier.deleteLayer(layer.id),
        );
      },
    );
  }
}

class _LayerListItem extends StatelessWidget {
  final Layer layer;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onVisibilityToggle;
  final VoidCallback onDelete;

  const _LayerListItem({
    super.key,
    required this.layer,
    required this.isSelected,
    required this.onTap,
    required this.onVisibilityToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366f1).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF6366f1) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withOpacity(0.1),
        image: DecorationImage(
          image: NetworkImage(layer.pngUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: layer.visible
          ? null
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black.withOpacity(0.6),
              ),
              child: const Icon(
                Icons.visibility_off,
                color: Colors.white54,
                size: 16,
              ),
            ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          layer.name,
          style: TextStyle(
            color: layer.visible ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'z: ${layer.zIndex}',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            layer.visible ? Icons.visibility : Icons.visibility_off,
            size: 18,
          ),
          color: layer.visible ? Colors.white70 : Colors.white38,
          onPressed: onVisibilityToggle,
          tooltip: layer.visible ? 'Hide layer' : 'Show layer',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          color: Colors.white38,
          onPressed: onDelete,
          tooltip: 'Delete layer',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        ReorderableDragStartListener(
          index: layer.zIndex,
          child: const Icon(Icons.drag_handle, size: 18, color: Colors.white38),
        ),
      ],
    );
  }
}
