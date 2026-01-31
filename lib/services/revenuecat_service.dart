import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat service for managing subscriptions and entitlements.
///
/// Handles initialization, purchase flow, and entitlement checking.
class RevenueCatService {
  static const String _entitlementId = 'Layers Pro';

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
    if (!_isInitialized) {
      debugPrint('RevenueCat: getOfferings called but not initialized');
      return null;
    }

    try {
      final offerings = await Purchases.getOfferings();
      debugPrint(
        'RevenueCat: Got offerings - current: ${offerings.current?.identifier}, '
        'packages: ${offerings.current?.availablePackages.length ?? 0}',
      );
      return offerings;
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
      final result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
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

  /// Get the export credits offering (consumable product).
  ///
  /// Returns the package for single export purchase, or null if not available.
  /// Expects an offering named 'export_credits' with a consumable package.
  Future<Package?> getExportPackage() async {
    if (!_isInitialized) {
      debugPrint('RevenueCat: getExportPackage called but not initialized');
      return null;
    }

    try {
      final offerings = await Purchases.getOfferings();
      final exportOffering = offerings.getOffering('export_credits');

      if (exportOffering == null) {
        debugPrint('RevenueCat: No export_credits offering found');
        return null;
      }

      // Get the first available package (should be the consumable)
      if (exportOffering.availablePackages.isEmpty) {
        debugPrint('RevenueCat: export_credits offering has no packages');
        return null;
      }

      // Log all available packages for debugging
      for (final p in exportOffering.availablePackages) {
        debugPrint(
          'RevenueCat: Available package: ${p.identifier} - '
          '${p.storeProduct.priceString} (${p.storeProduct.identifier})',
        );
      }

      // Prefer 'layers_export' package, fall back to first
      final package = exportOffering.availablePackages.firstWhere(
        (p) => p.identifier == 'layers_export',
        orElse: () => exportOffering.availablePackages.first,
      );
      debugPrint(
        'RevenueCat: Selected export package: ${package.identifier} - '
        '${package.storeProduct.priceString}',
      );
      return package;
    } catch (e) {
      debugPrint('RevenueCat: Failed to get export package: $e');
      return null;
    }
  }

  /// Purchase a consumable export credit.
  ///
  /// Unlike subscriptions, consumables don't grant entitlements.
  /// We just verify the purchase succeeded.
  Future<PurchaseResult> purchaseExportCredit(Package package) async {
    debugPrint(
      'RevenueCat: purchaseExportCredit called for ${package.identifier}',
    );

    if (!_isInitialized) {
      debugPrint('RevenueCat: Not initialized!');
      return PurchaseResult.error('RevenueCat not initialized');
    }

    try {
      debugPrint('RevenueCat: Calling Purchases.purchase(...)...');
      final result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      // For consumables, success means the purchase went through
      // No entitlement check needed - it's a one-time consumable
      debugPrint('RevenueCat: Export credit purchased successfully');
      debugPrint(
        'RevenueCat: CustomerInfo: ${result.customerInfo.originalAppUserId}',
      );
      return PurchaseResult.success(result.customerInfo);
    } catch (e, stackTrace) {
      debugPrint('RevenueCat: Purchase exception type: ${e.runtimeType}');
      debugPrint('RevenueCat: Purchase exception: $e');
      debugPrint('RevenueCat: Stack trace: $stackTrace');
      final errorStr = e.toString();
      if (errorStr.contains('cancelled') || errorStr.contains('canceled')) {
        debugPrint('RevenueCat: Purchase was cancelled');
        return PurchaseResult.cancelled();
      }
      debugPrint('RevenueCat: Export credit purchase failed: $e');
      return PurchaseResult.error('Purchase failed: $e');
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
