import 'package:flutter/foundation.dart';

/// Type of credit transaction
enum CreditTransactionType {
  /// Credits purchased via in-app purchase
  purchase,

  /// Credits consumed for an export
  consumption,

  /// Monthly bonus credits granted
  monthlyBonus,

  /// Credits refunded (e.g., for failed export)
  refund,
}

/// Extension for CreditTransactionType to provide string values
extension CreditTransactionTypeExtension on CreditTransactionType {
  String toJsonString() {
    switch (this) {
      case CreditTransactionType.purchase:
        return 'purchase';
      case CreditTransactionType.consumption:
        return 'consumption';
      case CreditTransactionType.monthlyBonus:
        return 'monthly_bonus';
      case CreditTransactionType.refund:
        return 'refund';
    }
  }

  static CreditTransactionType fromJsonString(String value) {
    switch (value) {
      case 'purchase':
        return CreditTransactionType.purchase;
      case 'consumption':
        return CreditTransactionType.consumption;
      case 'monthly_bonus':
        return CreditTransactionType.monthlyBonus;
      case 'refund':
        return CreditTransactionType.refund;
      default:
        throw ArgumentError('Unknown transaction type: $value');
    }
  }
}

/// Credit transaction model.
///
/// Represents a single credit transaction (purchase, consumption, bonus, or refund).
/// Stored in the credit_transactions table in Supabase.
@immutable
class CreditTransaction {
  const CreditTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.description,
    this.metadata,
    required this.createdAt,
  });

  /// Transaction UUID
  final String id;

  /// User UUID who owns this transaction
  final String userId;

  /// Type of transaction (purchase, consumption, monthlyBonus, refund)
  final CreditTransactionType type;

  /// Amount of credits (positive for credits added, negative for consumed)
  final int amount;

  /// Credits remaining after this transaction
  final int balanceAfter;

  /// Human-readable description of the transaction
  final String? description;

  /// Additional metadata (e.g., project_id, export_id, etc.)
  final Map<String, dynamic>? metadata;

  /// When the transaction occurred
  final DateTime createdAt;

  /// Create a copy with modified fields
  CreditTransaction copyWith({
    String? id,
    String? userId,
    CreditTransactionType? type,
    int? amount,
    int? balanceAfter,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return CreditTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Parse from Supabase JSON
  static CreditTransaction fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      type: CreditTransactionTypeExtension.fromJsonString(
        (json['type'] ?? '').toString(),
      ),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balance_after'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
    );
  }

  /// Serialize to Supabase JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user_id': userId,
        'type': type.toJsonString(),
        'amount': amount,
        'balance_after': balanceAfter,
        'description': description,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
      };
}
