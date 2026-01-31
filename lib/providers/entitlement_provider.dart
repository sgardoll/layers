import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
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
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Provider for entitlement state
final entitlementProvider =
    StateNotifierProvider<EntitlementNotifier, EntitlementState>((ref) {
      final revenueCatService = ref.watch(revenueCatServiceProvider);
      final projectListState = ref.watch(projectListProvider);

      return EntitlementNotifier(
        revenueCatService: revenueCatService,
        projectCount: projectListState.projects.length,
      );
    });

class EntitlementNotifier extends StateNotifier<EntitlementState> {
  final RevenueCatService _revenueCatService;

  EntitlementNotifier({
    required RevenueCatService revenueCatService,
    required int projectCount,
  }) : _revenueCatService = revenueCatService,
       super(EntitlementState(projectCount: projectCount)) {
    _init();
  }

  Future<void> _init() async {
    await checkEntitlements();
  }

  /// Check current entitlements from RevenueCat
  Future<void> checkEntitlements() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final isPro = await _revenueCatService.hasProEntitlement();
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

    try {
      final result = await _revenueCatService.purchasePackage(package);
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

    try {
      final result = await _revenueCatService.restorePurchases();

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
