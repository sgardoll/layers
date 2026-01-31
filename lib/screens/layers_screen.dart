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
        actions: [const ViewModeToggle(), const SizedBox(width: 8)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasLayers
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: viewMode == ViewMode.space3d
                      ? LayerSpaceView(
                          layers: layerState.layers,
                          selectedLayerId: layerState.selectedLayerId,
                          onLayerSelected: (id) =>
                              layerNotifier.selectLayer(id),
                        )
                      : const StackView2D(),
                ),
                const VerticalDivider(width: 1),
                const SizedBox(width: 280, child: LayerListPanel()),
              ],
            )
          : _buildEmptyState(context),
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

                return FloatingActionButton(
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
                );
              },
            )
          : null,
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
