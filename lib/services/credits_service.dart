import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/credit_transaction.dart';

/// User credits data model
@immutable
class UserCredits {
  const UserCredits({
    required this.userId,
    required this.creditsRemaining,
    required this.monthlyBonusCredits,
    this.lastBonusDate,
    this.updatedAt,
  });

  /// User UUID
  final String userId;

  /// Remaining credits available for export
  final int creditsRemaining;

  /// Monthly bonus credits (reset monthly)
  final int monthlyBonusCredits;

  /// When the last bonus was granted
  final DateTime? lastBonusDate;

  /// Last update timestamp
  final DateTime? updatedAt;

  UserCredits copyWith({
    String? userId,
    int? creditsRemaining,
    int? monthlyBonusCredits,
    DateTime? lastBonusDate,
    DateTime? updatedAt,
  }) {
    return UserCredits(
      userId: userId ?? this.userId,
      creditsRemaining: creditsRemaining ?? this.creditsRemaining,
      monthlyBonusCredits: monthlyBonusCredits ?? this.monthlyBonusCredits,
      lastBonusDate: lastBonusDate ?? this.lastBonusDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static UserCredits fromJson(Map<String, dynamic> json) {
    return UserCredits(
      userId: (json['user_id'] ?? '').toString(),
      creditsRemaining: (json['credits_remaining'] as num?)?.toInt() ?? 0,
      monthlyBonusCredits:
          (json['monthly_bonus_credits'] as num?)?.toInt() ?? 0,
      lastBonusDate: DateTime.tryParse(
        (json['last_bonus_date'] ?? '').toString(),
      ),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user_id': userId,
        'credits_remaining': creditsRemaining,
        'monthly_bonus_credits': monthlyBonusCredits,
        'last_bonus_date': lastBonusDate?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

/// Service for managing user credits and transactions
class CreditsService {
  final SupabaseClient _supabase;

  CreditsService({required SupabaseClient supabase}) : _supabase = supabase;

  /// Get current user's credits
  Future<UserCredits?> getUserCredits(String userId) async {
    try {
      final response = await _supabase
          .from('user_credits')
          .select()
          .eq('user_id', userId)
          .single();

      return UserCredits.fromJson(response);
    } catch (e) {
      debugPrint('CreditsService: Failed to get user credits: $e');
      return null;
    }
  }

  /// Consume one credit for an export
  /// Returns updated UserCredits on success, null on failure
  Future<UserCredits?> consumeCredit(
    String userId, {
    String? projectId,
    String? description,
  }) async {
    try {
      debugPrint('CreditsService: Consuming credit for user $userId');

      // Use the consume_credit RPC function if available
      // This handles the atomic decrement and transaction record atomically
      final response = await _supabase.rpc<Map<String, dynamic>>(
        'consume_credit',
        params: {
          'p_user_id': userId,
          'p_description': description ?? 'Export consumed',
          'p_metadata': <String, dynamic>{
            if (projectId != null) 'project_id': projectId,
          },
        },
      );

      final newBalance = response['new_balance'] as int?;
      if (newBalance == null) {
        debugPrint('CreditsService: No new_balance in response');
        return null;
      }

      debugPrint('CreditsService: Credit consumed, new balance: $newBalance');

      // Return updated UserCredits
      return UserCredits(
        userId: userId,
        creditsRemaining: newBalance,
        monthlyBonusCredits: 0, // Will be refreshed on next load
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      // If RPC doesn't exist, fall back to manual transaction
      if (e.toString().contains('does not exist') ||
          e.toString().contains('not found')) {
        debugPrint('CreditsService: RPC not available, using fallback');
        return _consumeCreditFallback(userId, projectId: projectId);
      }

      debugPrint('CreditsService: Failed to consume credit: $e');
      return null;
    }
  }

  /// Fallback method for credit consumption (manual transaction)
  Future<UserCredits?> _consumeCreditFallback(
    String userId, {
    String? projectId,
  }) async {
    try {
      // Get current balance
      final current = await getUserCredits(userId);
      if (current == null) {
        debugPrint('CreditsService: No user credits found');
        return null;
      }

      if (current.creditsRemaining <= 0) {
        debugPrint('CreditsService: No credits remaining');
        return null;
      }

      final newBalance = current.creditsRemaining - 1;

      // Update user_credits
      await _supabase
          .from('user_credits')
          .update({'credits_remaining': newBalance}).eq('user_id', userId);

      // Insert transaction record
      await _supabase.from('credit_transactions').insert({
        'user_id': userId,
        'type': 'consumption',
        'amount': -1,
        'balance_after': newBalance,
        'description': 'Export consumed',
        'metadata': <String, dynamic>{
          if (projectId != null) 'project_id': projectId,
        },
      });

      return current.copyWith(
        creditsRemaining: newBalance,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('CreditsService: Fallback consumption failed: $e');
      return null;
    }
  }

  /// Add credits to user's balance (for purchases or bonuses)
  Future<UserCredits?> addCredits(
    String userId,
    int amount,
    CreditTransactionType type, {
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    if (amount <= 0) {
      debugPrint('CreditsService: Cannot add non-positive amount: $amount');
      return null;
    }

    try {
      debugPrint('CreditsService: Adding $amount credits for user $userId');

      // Get current balance
      final current = await getUserCredits(userId);
      final currentBalance = current?.creditsRemaining ?? 0;
      final newBalance = currentBalance + amount;

      // Update or insert user_credits
      await _supabase.from('user_credits').upsert({
        'user_id': userId,
        'credits_remaining': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Insert transaction record
      await _supabase.from('credit_transactions').insert({
        'user_id': userId,
        'type': type.toJsonString(),
        'amount': amount,
        'balance_after': newBalance,
        'description': description ?? _getDefaultDescription(type),
        'metadata': metadata,
      });

      debugPrint('CreditsService: Credits added, new balance: $newBalance');

      return UserCredits(
        userId: userId,
        creditsRemaining: newBalance,
        monthlyBonusCredits: current?.monthlyBonusCredits ?? 0,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('CreditsService: Failed to add credits: $e');
      return null;
    }
  }

  String _getDefaultDescription(CreditTransactionType type) {
    switch (type) {
      case CreditTransactionType.purchase:
        return 'Credits purchased';
      case CreditTransactionType.monthlyBonus:
        return 'Monthly bonus credits';
      case CreditTransactionType.refund:
        return 'Credit refund';
      case CreditTransactionType.consumption:
        return 'Credits consumed';
    }
  }

  /// Get transaction history for a user
  Future<List<CreditTransaction>> getTransactionHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('credit_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final list = response as List<dynamic>;
      return list
          .map((json) =>
              CreditTransaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CreditsService: Failed to get transaction history: $e');
      return [];
    }
  }

  /// Subscribe to credit changes for a user
  /// Returns subscription object that should be disposed when done
  RealtimeChannel subscribeToCreditChanges(
    String userId,
    Function(UserCredits?) callback,
  ) {
    debugPrint(
        'CreditsService: Setting up realtime subscription for user $userId');

    final channel = _supabase.channel('user_credits_changes').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_credits',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            debugPrint('CreditsService: Realtime update received');
            final credits = UserCredits.fromJson(payload.newRecord);
            callback(credits);
          },
        );

    channel.subscribe();
    return channel;
  }

  /// Unsubscribe from credit changes
  void unsubscribeFromCreditChanges(RealtimeChannel channel) {
    debugPrint('CreditsService: Unsubscribing from credit changes');
    _supabase.removeChannel(channel);
  }
}
