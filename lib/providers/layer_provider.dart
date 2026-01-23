import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/layer.dart';

class LayerState {
  final List<Layer> layers;
  final String? selectedLayerId;
  final bool isLoading;

  const LayerState({
    this.layers = const [],
    this.selectedLayerId,
    this.isLoading = false,
  });

  LayerState copyWith({
    List<Layer>? layers,
    String? selectedLayerId,
    bool? isLoading,
    bool clearSelection = false,
  }) {
    return LayerState(
      layers: layers ?? this.layers,
      selectedLayerId: clearSelection
          ? null
          : (selectedLayerId ?? this.selectedLayerId),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Layer? get selectedLayer {
    if (selectedLayerId == null) return null;
    try {
      return layers.firstWhere((l) => l.id == selectedLayerId);
    } catch (_) {
      return null;
    }
  }
}

class LayerNotifier extends Notifier<LayerState> {
  @override
  LayerState build() => const LayerState();

  void setLayers(List<Layer> layers) {
    state = state.copyWith(layers: layers, clearSelection: true);
  }

  void selectLayer(String? layerId) {
    state = state.copyWith(
      selectedLayerId: layerId,
      clearSelection: layerId == null,
    );
  }

  void toggleSelection(String layerId) {
    if (state.selectedLayerId == layerId) {
      state = state.copyWith(clearSelection: true);
    } else {
      state = state.copyWith(selectedLayerId: layerId);
    }
  }

  void toggleVisibility(String layerId) {
    final updated = state.layers.map((layer) {
      if (layer.id == layerId) {
        return layer.copyWith(visible: !layer.visible);
      }
      return layer;
    }).toList();
    state = state.copyWith(layers: updated);
  }

  void renameLayer(String layerId, String newName) {
    final updated = state.layers.map((layer) {
      if (layer.id == layerId) {
        return layer.copyWith(name: newName);
      }
      return layer;
    }).toList();
    state = state.copyWith(layers: updated);
  }

  void reorderLayers(int oldIndex, int newIndex) {
    final layers = [...state.layers];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = layers.removeAt(oldIndex);
    layers.insert(newIndex, item);

    final reindexed = <Layer>[];
    for (var i = 0; i < layers.length; i++) {
      reindexed.add(layers[i].copyWith(zIndex: i));
    }

    state = state.copyWith(layers: reindexed);
  }

  void moveLayerUp(String layerId) {
    final index = state.layers.indexWhere((l) => l.id == layerId);
    if (index < state.layers.length - 1) {
      reorderLayers(index, index + 2);
    }
  }

  void moveLayerDown(String layerId) {
    final index = state.layers.indexWhere((l) => l.id == layerId);
    if (index > 0) {
      reorderLayers(index, index - 1);
    }
  }

  void deleteLayer(String layerId) {
    final updated = state.layers.where((l) => l.id != layerId).toList();
    final wasSelected = state.selectedLayerId == layerId;
    state = state.copyWith(layers: updated, clearSelection: wasSelected);
  }
}

final layerProvider = NotifierProvider<LayerNotifier, LayerState>(
  LayerNotifier.new,
);

final selectedLayerProvider = Provider<Layer?>((ref) {
  return ref.watch(layerProvider).selectedLayer;
});

final visibleLayersProvider = Provider<List<Layer>>((ref) {
  return ref.watch(layerProvider).layers.where((l) => l.visible).toList();
});
