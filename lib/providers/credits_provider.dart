import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../models/credit_transaction.dart';
import '../services/credits_service.dart';
import 'auth_provider.dart';

/// Provider for CreditsService instance
final creditsServiceProvider = Provider<CreditsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CreditsService(supabase: client);
});

/// Credit state for the current user
class CreditState {
  final int creditsRemaining;
  final int monthlyBonusCredits;
  final int totalExports;
  final bool isLoading;
  final String? errorMessage;

  const CreditState({
    this.creditsRemaining = 0,
    this.monthlyBonusCredits = 0,
    this.totalExports = 0,
    this.isLoading = true,
    this.errorMessage,
  });

  /// Whether user has credits available for export
  bool get hasCredits => creditsRemaining > 0;

  CreditState copyWith({
    int? creditsRemaining,
    int? monthlyBonusCredits,
    int? totalExports,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CreditState(
      creditsRemaining: creditsRemaining ?? this.creditsRemaining,
      monthlyBonusCredits: monthlyBonusCredits ?? this.monthlyBonusCredits,
      totalExports: totalExports ?? this.totalExports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for credit state management
/// Manages export credit balance with realtime updates from Supabase
final creditsProvider = StateNotifierProvider<CreditsNotifier, CreditState>((
  ref,
) {
  final creditsService = ref.watch(creditsServiceProvider);
  final user = ref.watch(currentUserProvider);

  return CreditsNotifier(
    creditsService: creditsService,
    userId: user?.id,
  );
}, dependencies: [creditsServiceProvider, currentUserProvider]);

class CreditsNotifier extends StateNotifier<CreditState> {
  final CreditsService _creditsService;
  String? _currentUserId;
  RealtimeChannel? _realtimeSubscription;

  CreditsNotifier({
    required CreditsService creditsService,
    String? userId,
  })  : _creditsService = creditsService,
        _currentUserId = userId,
        super(const CreditState(isLoading: true)) {
    _init(userId);
  }

  Future<void> _init(String? userId) async {
    if (userId != null) {
      await _handleUserChange(userId);
    } else {
      state = const CreditState(isLoading: false);
    }
  }

  /// Handle user login/logout changes
  Future<void> _handleUserChange(String? newUserId) async {
    // Clean up previous subscription
    _cleanupSubscription();

    _currentUserId = newUserId;

    if (newUserId != null) {
      debugPrint('CreditsNotifier: User logged in, loading credits');
      await loadCredits();
      _setupRealtimeListener(newUserId);
    } else {
      debugPrint('CreditsNotifier: User logged out, resetting state');
      state = const CreditState(isLoading: false);
    }
  }

  /// Set up Supabase realtime listener for credit changes
  void _setupRealtimeListener(String userId) {
    debugPrint('CreditsNotifier: Setting up realtime listener');

    _realtimeSubscription = _creditsService.subscribeToCreditChanges(
      userId,
      (credits) {
        if (credits != null) {
          debugPrint(
            'CreditsNotifier: Realtime update - credits: ${credits.creditsRemaining}',
          );
          state = state.copyWith(
            creditsRemaining: credits.creditsRemaining,
            monthlyBonusCredits: credits.monthlyBonusCredits,
            isLoading: false,
            errorMessage: null,
          );
        }
      },
    );
  }

  /// Clean up realtime subscription
  void _cleanupSubscription() {
    if (_realtimeSubscription != null) {
      debugPrint('CreditsNotifier: Cleaning up realtime subscription');
      _creditsService.unsubscribeFromCreditChanges(_realtimeSubscription!);
      _realtimeSubscription = null;
    }
  }

  /// Load current user's credits from Supabase
  Future<void> loadCredits() async {
    if (_currentUserId == null) {
      state = const CreditState(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final credits = await _creditsService.getUserCredits(_currentUserId!);

      if (credits != null) {
        state = state.copyWith(
          creditsRemaining: credits.creditsRemaining,
          monthlyBonusCredits: credits.monthlyBonusCredits,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        // No credits record yet - user has 0 credits
        state = const CreditState(
          creditsRemaining: 0,
          monthlyBonusCredits: 0,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('CreditsNotifier: Failed to load credits: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load credits',
      );
    }
  }

  /// Refresh credits from server
  Future<void> refresh() async {
    await loadCredits();
  }

  /// Consume one credit for an export
  /// Returns true on success, false on failure
  Future<bool> consumeCredit({String? projectId, String? description}) async {
    if (_currentUserId == null) {
      state = state.copyWith(errorMessage: 'Not logged in');
      return false;
    }

    if (state.creditsRemaining <= 0) {
      state = state.copyWith(errorMessage: 'No credits remaining');
      return false;
    }

    // Optimistically update UI
    final previousCredits = state.creditsRemaining;
    state = state.copyWith(
      creditsRemaining: previousCredits - 1,
      totalExports: state.totalExports + 1,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _creditsService.consumeCredit(
        _currentUserId!,
        projectId: projectId,
        description: description ?? 'Export consumed',
      );

      if (result != null) {
        // Success - update with server value
        state = state.copyWith(
          creditsRemaining: result.creditsRemaining,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        // Failed - rollback optimistic update
        state = state.copyWith(
          creditsRemaining: previousCredits,
          totalExports: state.totalExports - 1,
          isLoading: false,
          errorMessage: 'Failed to consume credit',
        );
        return false;
      }
    } catch (e) {
      debugPrint('CreditsNotifier: Consume credit error: $e');
      // Rollback optimistic update
      state = state.copyWith(
        creditsRemaining: previousCredits,
        totalExports: state.totalExports - 1,
        isLoading: false,
        errorMessage: 'Failed to consume credit: $e',
      );
      return false;
    }
  }

  /// Add credits (called after successful purchase)
  Future<bool> addCredits(
    int amount,
    CreditTransactionType type, {
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUserId == null) {
      state = state.copyWith(errorMessage: 'Not logged in');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _creditsService.addCredits(
        _currentUserId!,
        amount,
        type,
        description: description,
        metadata: metadata,
      );

      if (result != null) {
        state = state.copyWith(
          creditsRemaining: result.creditsRemaining,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to add credits',
        );
        return false;
      }
    } catch (e) {
      debugPrint('CreditsNotifier: Add credits error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add credits: $e',
      );
      return false;
    }
  }

  /// Reset state (called on logout)
  void reset() {
    _cleanupSubscription();
    state = const CreditState(isLoading: false);
  }

  @override
  void dispose() {
    _cleanupSubscription();
    super.dispose();
  }
}

/// Simple provider to check if user has credits available
final hasCreditsProvider = Provider<bool>((ref) {
  final credits = ref.watch(creditsProvider);
  return credits.hasCredits;
});

/// Provider for remaining credits count
final creditsRemainingProvider = Provider<int>((ref) {
  final credits = ref.watch(creditsProvider);
  return credits.creditsRemaining;
});
