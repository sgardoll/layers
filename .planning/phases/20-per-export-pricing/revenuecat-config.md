# RevenueCat Consumable Configuration

This document describes the RevenueCat dashboard configuration for the per-export pricing feature.

## Overview

The Layers app uses RevenueCat to manage both subscription entitlements and consumable in-app purchases for export credits.

- **Offering**: `export_credits`
- **Package**: `layers_export`
- **Product**: Consumable IAP for single export credit

## Dashboard Setup

### 1. RevenueCat Product

1. Go to [app.revenuecat.com](https://app.revenuecat.com)
2. Select your project
3. Navigate to **Products > Add new product**
4. Configure:
   - **Identifier**: `layers_export`
   - **Display Name**: "Export Credit"
   - **Description**: "Single export credit for one-time layer export"

### 2. RevenueCat Offering

1. Navigate to **Offerings > Add offering**
2. Configure:
   - **Identifier**: `export_credits`
   - **Display Name**: "Export Credits"
3. Add package to offering:
   - **Identifier**: `layers_export`
   - **Product**: Select `layers_export` product
   - **Display Name**: "Single Export"

## Platform Configuration

### App Store Connect (iOS/macOS)

1. Go to [App Store Connect](https://appstoreconnect.apple.com) > Your App > Features > In-App Purchases
2. Create consumable IAP:
   - **Reference Name**: "Export Credit"
   - **Product ID**: `com.connectio.layers.export_credit`
   - **Price**: Tier 1 ($0.99) or Tier 0 ($0.49 if available in your region)
   - **Type**: Consumable

### Google Play Console (Android)

1. Go to [Play Console](https://play.google.com/console) > Your App > Monetize > Products > In-app products
2. Create managed product:
   - **Product ID**: `layers_export_credit`
   - **Name**: "Export Credit"
   - **Price**: $0.50 USD
   - **Type**: Consumable

## Code Integration

The app expects these identifiers:

```dart
// Offering identifier
const String exportCreditsOfferingId = 'export_credits';

// Package identifier
const String exportPackageId = 'layers_export';
```

See `lib/services/revenuecat_service.dart` for the implementation.

## Testing Notes

### Sandbox Testing

- Test consumables in sandbox environment before production
- Consumables can be purchased multiple times (unlike subscriptions)

### Platform-Specific Behavior

- **iOS**: Consumables must be consumed via the RevenueCat API or they'll auto-restore on app reinstall
- **Android**: Consumables can be repurchased without consuming in test environments (known quirk)

### Test Scenarios

1. Purchase export credit
2. Verify credit is added to user balance
3. Use credit for export
4. Verify credit is deducted
5. Purchase multiple credits in succession
6. Restore purchases (should not restore consumables, by design)

## Environment Variables

Add to `.env`:

```
# RevenueCat Export Credit Product IDs (optional - for per-export pricing)
# REVENUECAT_EXPORT_PRODUCT_ID_IOS=com.connectio.layers.export_credit
# REVENUECAT_EXPORT_PRODUCT_ID_ANDROID=layers_export_credit
```

## Related Files

- `lib/services/revenuecat_service.dart` - RevenueCat integration
- `.env.example` - Environment variable template
- `.planning/phases/20-per-export-pricing/` - Implementation plans

---

*Configuration verified: 2026-02-07*
