import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layer.dart';
import '../providers/layer_provider.dart';

class LayerListPanel extends ConsumerWidget {
  final double width;
  final bool showHeader;

  const LayerListPanel({super.key, this.width = 280, this.showHeader = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layerState = ref.watch(layerProvider);
    final layerNotifier = ref.read(layerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          if (showHeader) _buildHeader(context),
          Expanded(
            child: layerState.layers.isEmpty
                ? _buildEmptyState(context)
                : _buildLayerList(context, layerState, layerNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.layers, color: colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 8),
          Text(
            'Layers',
            style: TextStyle(
              color: colorScheme.onSurface,
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
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: colorScheme.outline,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No layers yet',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Import an image to get started',
            style: TextStyle(color: colorScheme.outline, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerList(
    BuildContext context,
    LayerState layerState,
    LayerNotifier notifier,
  ) {
    // Sort layers by zIndex descending so highest Z (front-most) appears at top
    // This matches design tool conventions (Photoshop, Figma, etc.)
    final sortedLayers = [...layerState.layers]
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedLayers.length,
      onReorder: (oldIndex, newIndex) {
        // Convert visual indices to actual layer indices in the state
        final actualOldIndex = layerState.layers.indexWhere(
          (l) => l.id == sortedLayers[oldIndex].id,
        );
        final actualNewIndex = layerState.layers.indexWhere(
          (l) =>
              l.id ==
              sortedLayers[newIndex > oldIndex ? newIndex - 1 : newIndex].id,
        );
        notifier.reorderLayers(actualOldIndex, actualNewIndex);
      },
      itemBuilder: (context, index) {
        final layer = sortedLayers[index];
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
    final colorScheme = Theme.of(context).colorScheme;

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
                ? colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              _buildThumbnail(context),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo(context)),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: colorScheme.surfaceContainerHighest,
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
              child: Icon(
                Icons.visibility_off,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          layer.name,
          style: TextStyle(
            color: layer.visible
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'z: ${layer.zIndex}',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            layer.visible ? Icons.visibility : Icons.visibility_off,
            size: 18,
          ),
          color: layer.visible
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
          onPressed: onVisibilityToggle,
          tooltip: layer.visible ? 'Hide layer' : 'Show layer',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          color: colorScheme.onSurfaceVariant,
          onPressed: onDelete,
          tooltip: 'Delete layer',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        ReorderableDragStartListener(
          index: layer.zIndex,
          child: Icon(
            Icons.drag_handle,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
