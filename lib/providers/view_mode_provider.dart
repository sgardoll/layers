import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewMode { space3d, stack2d }

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.space3d;

  void toggle() {
    state = state == ViewMode.space3d ? ViewMode.stack2d : ViewMode.space3d;
  }

  void setMode(ViewMode mode) {
    state = mode;
  }
}

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(
  ViewModeNotifier.new,
);
