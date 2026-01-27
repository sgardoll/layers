import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase_client.dart';
import 'providers/entitlement_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'services/revenuecat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  // Initialize RevenueCat for subscriptions
  final revenueCat = RevenueCatService();
  await revenueCat.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Pass the initialized RevenueCat instance to the provider system
        revenueCatServiceProvider.overrideWithValue(revenueCat),
      ],
      child: const LayersApp(),
    ),
  );
}

class LayersApp extends ConsumerWidget {
  const LayersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Layers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
