import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../providers/layer_provider.dart';
import '../providers/project_provider.dart';
import '../providers/view_mode_provider.dart';
import '../services/supabase_project_service.dart';
import '../widgets/export_bottom_sheet.dart';
import '../widgets/layer_space_view.dart';
import '../widgets/stack_view_2d.dart';
import '../widgets/layer_list_panel.dart';
import '../widgets/view_mode_toggle.dart';
import '../widgets/responsive_layout.dart';

/// Provider that fetches layers for the current project
final _layersFetchProvider = FutureProvider.autoDispose<void>((ref) async {
  final project = ref.watch(currentProjectProvider);
  if (project == null) return;

  final service = ref.read(supabaseProjectServiceProvider);
  final result = await service.getProjectLayers(project.id);

  result.when(
    success: (layers) {
      ref.read(layerProvider.notifier).setLayers(layers);
    },
    failure: (message, error) {
      // Layers fetch failed - layerProvider will remain empty
      // Could add error handling UI if needed
    },
  );
});

class LayersScreen extends ConsumerWidget {
  const LayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger layer fetch when screen loads
    ref.watch(_layersFetchProvider);

    final viewMode = ref.watch(viewModeProvider);
    final layerState = ref.watch(layerProvider);
    final layerNotifier = ref.read(layerProvider.notifier);
    final isLoading = ref.watch(_layersFetchProvider).isLoading;
    final hasLayers = layerState.layers.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Layers'),
        centerTitle: true,
        actions: [
          const ViewModeToggle(),
          if (hasLayers) ...[
            const SizedBox(width: 8),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.layers),
                  tooltip: 'Show layers',
                  onPressed: () => _showLayersBottomSheet(context, ref),
                );
              },
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!hasLayers) {
            return _buildEmptyState(context);
          }

          // Desktop/Tablet layout: side-by-side
          if (constraints.maxWidth >= Breakpoints.mobile) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildViewer(viewMode, layerState, layerNotifier),
                ),
                const VerticalDivider(width: 1),
                const SizedBox(width: 280, child: LayerListPanel()),
              ],
            );
          }

          // Mobile layout: full-screen viewer with FAB for layers
          return Stack(
            children: [
              Positioned.fill(
                child: _buildViewer(viewMode, layerState, layerNotifier),
              ),
            ],
          );
        },
      ),
      floatingActionButton: hasLayers
          ? Builder(
              builder: (context) {
                final project = ref.watch(currentProjectProvider);
                final selectedLayer = layerState.selectedLayerId != null
                    ? layerState.layers.firstWhere(
                        (l) => l.id == layerState.selectedLayerId,
                        orElse: () => layerState.layers.first,
                      )
                    : null;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Layers FAB (mobile only - hidden on desktop)
                    if (MediaQuery.of(context).size.width < Breakpoints.mobile)
                      FloatingActionButton.small(
                        heroTag: 'layers_fab',
                        onPressed: () => _showLayersBottomSheet(context, ref),
                        tooltip: 'Layers',
                        child: const Icon(Icons.layers),
                      ),
                    const SizedBox(height: 8),
                    // Export FAB
                    FloatingActionButton(
                      heroTag: 'export_fab',
                      onPressed: () {
                        if (project == null) return;
                        ExportBottomSheet.show(
                          context,
                          layers: layerState.layers,
                          projectName: project.name,
                          projectId: project.id,
                          selectedLayer: selectedLayer,
                        );
                      },
                      tooltip: 'Export',
                      child: const Icon(Icons.ios_share),
                    ),
                  ],
                );
              },
            )
          : null,
    );
  }

  Widget _buildViewer(
    ViewMode viewMode,
    LayerState layerState,
    LayerNotifier layerNotifier,
  ) {
    return viewMode == ViewMode.space3d
        ? LayerSpaceView(
            layers: layerState.layers,
            selectedLayerId: layerState.selectedLayerId,
            onLayerSelected: (id) => layerNotifier.selectLayer(id),
          )
        : const StackView2D();
  }

  void _showLayersBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.layers,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Layers',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Layer list
                Expanded(
                  child: LayerListPanel(
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            '3D Layer View',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Import an image to see layers here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
