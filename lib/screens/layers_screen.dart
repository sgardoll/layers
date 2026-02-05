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

/// Enum for the 3-tab navigation: 3D, 2D, Layers
enum LayerViewTab { threeD, twoD, layers }

/// Provider for the selected tab in the AppBar
final layerViewTabProvider = StateProvider<LayerViewTab>(
  (ref) => LayerViewTab.threeD,
);

/// Provider to track if layers panel is visible (for mobile bottom sheet)
final layersPanelVisibleProvider = StateProvider<bool>((ref) => false);

class LayersScreen extends ConsumerStatefulWidget {
  const LayersScreen({super.key});

  @override
  ConsumerState<LayersScreen> createState() => _LayersScreenState();
}

class _LayersScreenState extends ConsumerState<LayersScreen> {
  @override
  Widget build(BuildContext context) {
    // Trigger layer fetch when screen loads
    ref.watch(_layersFetchProvider);

    final viewMode = ref.watch(viewModeProvider);
    final layerState = ref.watch(layerProvider);
    final layerNotifier = ref.read(layerProvider.notifier);
    final isLoading = ref.watch(_layersFetchProvider).isLoading;
    final hasLayers = layerState.layers.isNotEmpty;
    final selectedTab = ref.watch(layerViewTabProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Sync view mode with tab selection
    // When tab changes, update view mode accordingly
    if (selectedTab == LayerViewTab.threeD && viewMode != ViewMode.space3d) {
      Future.microtask(() {
        ref.read(viewModeProvider.notifier).setMode(ViewMode.space3d);
      });
    } else if (selectedTab == LayerViewTab.twoD &&
        viewMode != ViewMode.stack2d) {
      Future.microtask(() {
        ref.read(viewModeProvider.notifier).setMode(ViewMode.stack2d);
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < Breakpoints.mobile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Layers'),
        centerTitle: true,
        actions: [
          if (hasLayers) ...[
            // Tab Navigation: 3D / 2D (always shown) + Layers (mobile only)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabButton(
                    icon: Icons.view_in_ar,
                    label: '3D',
                    isSelected: selectedTab == LayerViewTab.threeD,
                    onTap: () {
                      ref.read(layerViewTabProvider.notifier).state =
                          LayerViewTab.threeD;
                      ref.read(layersPanelVisibleProvider.notifier).state =
                          false;
                    },
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                  _buildTabButton(
                    icon: Icons.layers,
                    label: '2D',
                    isSelected: selectedTab == LayerViewTab.twoD,
                    onTap: () {
                      ref.read(layerViewTabProvider.notifier).state =
                          LayerViewTab.twoD;
                      ref.read(layersPanelVisibleProvider.notifier).state =
                          false;
                    },
                  ),
                  // Only show Layers tab on mobile (when side panel is not visible)
                  if (isMobile) ...[
                    Container(
                      width: 1,
                      height: 32,
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                    _buildTabButton(
                      icon: Icons.list,
                      label: 'Layers',
                      isSelected: selectedTab == LayerViewTab.layers,
                      onTap: () {
                        ref.read(layerViewTabProvider.notifier).state =
                            LayerViewTab.layers;
                        // On mobile, show bottom sheet when Layers tab selected
                        _showLayersBottomSheet(context, ref);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
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

                // Only show Export FAB - Layers is now accessed via the 3rd tab
                return FloatingActionButton(
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
                // Layer list (no header since bottom sheet has its own)
                Expanded(
                  child: LayerListPanel(
                    width: MediaQuery.of(context).size.width,
                    showHeader: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      // When bottom sheet is dismissed, deselect Layers tab
      // Switch back to the tab matching current view mode
      if (mounted) {
        final currentViewMode = ref.read(viewModeProvider);
        final newTab = currentViewMode == ViewMode.space3d
            ? LayerViewTab.threeD
            : LayerViewTab.twoD;
        ref.read(layerViewTabProvider.notifier).state = newTab;
      }
    });
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
