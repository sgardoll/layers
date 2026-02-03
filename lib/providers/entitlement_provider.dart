import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import 'auth_provider.dart';
import 'project_provider.dart';

/// Entitlement state for the current user
class EntitlementState {
  final bool isPro;
  final int projectCount;
  final int freeProjectLimit;
  final bool isLoading;
  final String? errorMessage;

  const EntitlementState({
    this.isPro = false,
    this.projectCount = 0,
    this.freeProjectLimit = 3,
    this.isLoading = true,
    this.errorMessage,
  });

  /// Whether user can create more projects
  bool get canCreateProject => isPro || projectCount < freeProjectLimit;

  /// Projects remaining on free tier
  int get remainingFreeProjects =>
      isPro ? -1 : (freeProjectLimit - projectCount).clamp(0, freeProjectLimit);

  EntitlementState copyWith({
    bool? isPro,
    int? projectCount,
    int? freeProjectLimit,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EntitlementState(
      isPro: isPro ?? this.isPro,
      projectCount: projectCount ?? this.projectCount,
      freeProjectLimit: freeProjectLimit ?? this.freeProjectLimit,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for RevenueCat service
/// NOTE: This is a singleton that persists across the app lifecycle.
/// User-specific state is managed via logIn/logOut, not provider recreation.
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Provider that links RevenueCat to the current authenticated user
/// This ensures RevenueCat customer info is properly scoped to the user
final linkedRevenueCatServiceProvider = FutureProvider<RevenueCatService>((
  ref,
) async {
  final service = ref.watch(revenueCatServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user != null) {
    // Link this RevenueCat session to the authenticated user
    await service.logIn(user.id);
    debugPrint('RevenueCat: Linked to user ${user.id}');
  } else {
    // CRITICAL FIX: Explicitly log out when user is null (anonymous)
    // This prevents cached Pro entitlements from leaking to new/anonymous users
    await service.logOut();
    debugPrint('RevenueCat: Logged out for anonymous session');
  }

  return service;
});

/// Provider for entitlement state
/// Watches the linked RevenueCat service so it re-initializes when user changes
final entitlementProvider =
    StateNotifierProvider<EntitlementNotifier, EntitlementState>((ref) {
      final linkedServiceAsync = ref.watch(linkedRevenueCatServiceProvider);
      final projectListState = ref.watch(projectListProvider);

      // CRITICAL FIX: Wait for linked service to complete before using it
      // If it's still loading, return a notifier in loading state
      if (linkedServiceAsync.isLoading) {
        return EntitlementNotifier.loading(
          projectCount: projectListState.projects.length,
        );
      }

      if (linkedServiceAsync.hasError || linkedServiceAsync.value == null) {
        // Fallback to unlinked service if something went wrong
        final fallbackService = ref.read(revenueCatServiceProvider);
        return EntitlementNotifier(
          revenueCatService: fallbackService,
          projectCount: projectListState.projects.length,
        );
      }

      // Linked service is ready - use it
      return EntitlementNotifier(
        revenueCatService: linkedServiceAsync.requireValue,
        projectCount: projectListState.projects.length,
      );
    });

class EntitlementNotifier extends StateNotifier<EntitlementState> {
  final RevenueCatService? _revenueCatService;

  EntitlementNotifier({
    required RevenueCatService revenueCatService,
    required int projectCount,
  }) : _revenueCatService = revenueCatService,
       super(EntitlementState(projectCount: projectCount)) {
    _init();
  }

  /// Factory constructor for loading state (used when linked service is still initializing)
  factory EntitlementNotifier.loading({required int projectCount}) {
    return EntitlementNotifier._internal(
      revenueCatService: null,
      projectCount: projectCount,
      isLoading: true,
    );
  }

  /// Internal constructor for special states
  EntitlementNotifier._internal({
    required RevenueCatService? revenueCatService,
    required int projectCount,
    bool isLoading = false,
  }) : _revenueCatService = revenueCatService,
       super(
         EntitlementState(projectCount: projectCount, isLoading: isLoading),
       );

  Future<void> _init() async {
    if (_revenueCatService != null) {
      await checkEntitlements();
    }
  }

  /// Check current entitlements from RevenueCat
  Future<void> checkEntitlements() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Check if service is available (may be null during loading state)
    if (_revenueCatService == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Subscription service not ready',
      );
      return;
    }

    try {
      final isPro = await _revenueCatService!.hasProEntitlement();
      state = state.copyWith(isPro: isPro, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to check subscription status',
      );
    }
  }

  /// Update project count (called when projects change)
  void updateProjectCount(int count) {
    state = state.copyWith(projectCount: count);
  }

  /// Purchase pro subscription using a package
  Future<bool> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Check if service is available
    if (_revenueCatService == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Subscription service not ready',
      );
      return false;
    }

    try {
      final result = await _revenueCatService!.purchasePackage(package);
      if (result.isSuccess) {
        state = state.copyWith(isPro: true, isLoading: false);
        return true;
      } else if (result.isCancelled) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null, // User cancelled, no error
        );
        return false;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? 'Purchase failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Purchase failed: $e',
      );
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Check if service is available
    if (_revenueCatService == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Subscription service not ready',
      );
      return false;
    }

    try {
      final result = await _revenueCatService!.restorePurchases();

      if (result.isSuccess) {
        state = state.copyWith(isPro: true, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? 'No purchases to restore',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Restore failed: $e',
      );
      return false;
    }
  }

  /// Reset entitlement state (called on logout)
  void reset() {
    state = const EntitlementState(isLoading: false);
  }
}

/// Simple provider to check if user can create projects
final canCreateProjectProvider = Provider<bool>((ref) {
  final entitlement = ref.watch(entitlementProvider);
  return entitlement.canCreateProject;
});

/// Provider for remaining free projects
final remainingFreeProjectsProvider = Provider<int>((ref) {
  final entitlement = ref.watch(entitlementProvider);
  return entitlement.remainingFreeProjects;
});
