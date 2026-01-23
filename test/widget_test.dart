import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:layers/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LayersApp()));

    expect(find.text('Layers'), findsOneWidget);
    expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
  });
}
