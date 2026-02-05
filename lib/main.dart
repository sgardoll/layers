import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase_client.dart';
import 'providers/entitlement_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'services/revenuecat_service.dart';
import 'widgets/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: LayersApp(),
    ),
  );
}

final _initializationProvider = FutureProvider<RevenueCatService>((ref) async {
  await initSupabase();
  final revenueCat = RevenueCatService();
  await revenueCat.initialize();
  return revenueCat;
});

class LayersApp extends ConsumerWidget {
  const LayersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(_initializationProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
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
      home: initialization.when(
        data: (revenueCat) => ProviderScope(
          overrides: [
            revenueCatServiceProvider.overrideWithValue(revenueCat),
          ],
          child: const _InitializedApp(),
        ),
        loading: () => const SplashScreen(
          isInitialized: false,
          child: SizedBox.shrink(),
        ),
        error: (error, stack) => Scaffold(
          backgroundColor: SplashScreen.backgroundColor,
          body: Center(
            child: Text(
              'Failed to initialize: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _InitializedApp extends ConsumerWidget {
  const _InitializedApp();

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
