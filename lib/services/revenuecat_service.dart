import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat service for managing subscriptions and entitlements.
///
/// Handles initialization, purchase flow, and entitlement checking.
class RevenueCatService {
  static const String _entitlementId = 'pro';

  bool _isInitialized = false;

  /// Initialize RevenueCat with platform-specific API keys.
  ///
  /// Call this once at app startup, after Supabase is initialized.
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;

    final iosKey = dotenv.env['REVENUECAT_IOS_KEY'] ?? '';
    final androidKey = dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';

    if (iosKey.isEmpty && androidKey.isEmpty) {
      debugPrint('RevenueCat: No API keys configured, skipping initialization');
      return;
    }

    final apiKey = Platform.isIOS || Platform.isMacOS ? iosKey : androidKey;

    if (apiKey.isEmpty) {
      debugPrint('RevenueCat: No API key for current platform');
      return;
    }

    final configuration = PurchasesConfiguration(apiKey);
    if (userId != null) {
      configuration.appUserID = userId;
    }

    await Purchases.configure(configuration);
    _isInitialized = true;
    debugPrint('RevenueCat: Initialized successfully');
  }

  /// Check if RevenueCat is properly initialized.
  bool get isInitialized => _isInitialized;

  /// Get current customer info including entitlements.
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isInitialized) return null;

    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCat: Failed to get customer info: $e');
      return null;
    }
  }

  /// Check if user has active Pro entitlement.
  Future<bool> hasProEntitlement() async {
    final customerInfo = await getCustomerInfo();
    if (customerInfo == null) return false;

    return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
  }

  /// Get available subscription offerings.
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) return null;

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat: Failed to get offerings: $e');
      return null;
    }
  }

  /// Purchase a package (subscription product).
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!_isInitialized) {
      return PurchaseResult.error('RevenueCat not initialized');
    }

    try {
      final result = await Purchases.purchasePackage(package);
      final customerInfo = result.customerInfo;
      final isPro =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      if (isPro) {
        return PurchaseResult.success(customerInfo);
      } else {
        return PurchaseResult.error(
          'Purchase completed but entitlement not active',
        );
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('cancelled') || errorStr.contains('canceled')) {
        return PurchaseResult.cancelled();
      }
      return PurchaseResult.error('Purchase failed: $e');
    }
  }

  /// Restore previous purchases.
  Future<PurchaseResult> restorePurchases() async {
    if (!_isInitialized) {
      return PurchaseResult.error('RevenueCat not initialized');
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      if (isPro) {
        return PurchaseResult.success(customerInfo);
      } else {
        return PurchaseResult.error('No active subscription found');
      }
    } catch (e) {
      return PurchaseResult.error('Restore failed: $e');
    }
  }

  /// Log in a user (link purchases to user ID).
  Future<void> logIn(String userId) async {
    if (!_isInitialized) return;

    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat: Failed to log in user: $e');
    }
  }

  /// Log out current user (for anonymous purchases).
  Future<void> logOut() async {
    if (!_isInitialized) return;

    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat: Failed to log out: $e');
    }
  }
}

/// Result of a purchase operation.
class PurchaseResult {
  final PurchaseStatus status;
  final CustomerInfo? customerInfo;
  final String? errorMessage;

  PurchaseResult._({
    required this.status,
    this.customerInfo,
    this.errorMessage,
  });

  factory PurchaseResult.success(CustomerInfo info) =>
      PurchaseResult._(status: PurchaseStatus.success, customerInfo: info);

  factory PurchaseResult.cancelled() =>
      PurchaseResult._(status: PurchaseStatus.cancelled);

  factory PurchaseResult.error(String message) =>
      PurchaseResult._(status: PurchaseStatus.error, errorMessage: message);

  bool get isSuccess => status == PurchaseStatus.success;
  bool get isCancelled => status == PurchaseStatus.cancelled;
  bool get isError => status == PurchaseStatus.error;
}

enum PurchaseStatus { success, cancelled, error }
