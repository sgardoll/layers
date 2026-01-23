# 03-02 Summary: Layer Selection and Actions

## Implemented
- `LayerState` - layers list, selectedLayerId, visibility map
- `LayerNotifier` - setLayers, select, toggleVisibility, reorder, delete
- `LayerListPanel` - Side panel with draggable layer tiles
- ReorderableListView for drag-to-reorder
- Visibility toggle (eye icon), delete action

## Key Patterns
- Selection syncs between 3D view and list panel
- Layer order persists via zIndex recalculation on reorder
- Visual feedback: selected = accent border, hidden = opacity 0.5
- Thumbnail preview in list tiles

## Files
- lib/providers/layer_provider.dart
- lib/widgets/layer_list_panel.dart
