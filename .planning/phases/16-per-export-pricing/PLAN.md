# Phase 16: Per-Export Pricing

## Goal
Add $0.50 consumable IAP as pay-per-export option alongside Pro subscription.

## Current State
- RevenueCat initialized with subscription (`Layers Pro` entitlement)
- Export flow in `ExportBottomSheet._startExport()` has no payment gate
- No consumable products configured

## Design

### Pricing Model
| User Type | Export Cost |
|-----------|-------------|
| Pro subscriber | Free (unlimited) |
| Free user | $0.50 per export |

### RevenueCat Setup (Manual)
1. Create consumable product in App Store Connect & Google Play Console
   - Product ID: `layers_single_export`
   - Price: $0.50 USD
2. Add product to RevenueCat dashboard
3. Create "Export Credits" offering with consumable package

### User Flow
1. User taps export option
2. Check `hasProEntitlement()`
3. If Pro → proceed to export
4. If Free → show purchase sheet ($0.50)
5. On successful purchase → proceed to export
6. On cancel/fail → return to export options

## Plans

### 16-01: RevenueCat Consumable Support
- Add `purchaseConsumable()` method to `RevenueCatService`
- Add `getExportOffering()` to fetch consumable package
- Handle consumable purchase flow (no entitlement check needed)

### 16-02: Export Payment Gate
- Create `ExportPurchaseSheet` widget for purchase UI
- Modify `ExportBottomSheet._startExport()` to check Pro status
- If not Pro, show purchase sheet before proceeding
- Track purchase success before allowing export

### 16-03: Testing & Verification
- Test Pro user flow (should skip payment)
- Test free user purchase flow
- Test cancel/restore scenarios
- Verify on iOS and Android

## Files to Modify
- `lib/services/revenuecat_service.dart` - Add consumable methods
- `lib/widgets/export_bottom_sheet.dart` - Add payment gate
- `lib/widgets/export_purchase_sheet.dart` - New widget (purchase UI)

## Dependencies
- RevenueCat consumable product configured in dashboard
- App Store Connect / Play Console products created

## Success Criteria
- [ ] Pro users export without payment prompt
- [ ] Free users see $0.50 purchase before export
- [ ] Purchase completes and export proceeds
- [ ] Cancel returns to export options gracefully
