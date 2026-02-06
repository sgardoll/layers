---
phase: 20-per-export-pricing
plan: 05
subsystem: payments
tags: [flutter, revenuecat, riverpod, consumable, iap]

# Dependency graph
requires:
  - phase: 20-03
    provides: CreditsProvider with realtime subscription and credit management
provides:
  - Reusable PurchaseButton widget with price display and states
  - PurchaseCreditScreen for consumable credit purchases
  - Integration with ExportBottomSheet purchase flow
  - Restore purchases functionality for consumables
affects:
  - Export flow UX
  - Purchase UI consistency

# Tech tracking
tech-stack:
  added: []
  patterns:
    - ConsumerStatefulWidget with Riverpod for purchase screens
    - Reusable button widgets with loading/error states
    - Modal bottom sheet navigation for purchase flow

key-files:
  created:
    - lib/widgets/purchase_button.dart
    - lib/screens/purchase_credit_screen.dart
  modified:
    - lib/widgets/export_bottom_sheet.dart

key-decisions:
  - Created reusable PurchaseButton widget for consistent purchase CTAs
  - Used ConsumerStatefulWidget pattern matching PaywallScreen
  - Integrated PurchaseCreditScreen into ExportBottomSheet flow
  - Kept ExportPurchaseSheet as alternative (not removed)

patterns-established:
  - PurchaseButton: Reusable widget with price, loading, disabled, and error states
  - PurchaseCreditScreen.show(): Returns bool for success/failure
  - Credits added automatically after successful RevenueCat purchase

issues-created: []

# Metrics
duration: 12min
completed: 2026-02-07
---

# Phase 20 Plan 05: Purchase Flow UI and Integration

**Reusable PurchaseButton widget, PurchaseCreditScreen with Riverpod integration, and ExportBottomSheet purchase flow**

## Performance

- **Duration:** 12 min
- **Started:** 2026-02-07T06:30:00Z
- **Completed:** 2026-02-07T06:42:00Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments

- Created reusable `PurchaseButton` widget with price display, loading state, disabled state, and error message support
- Built `PurchaseCreditScreen` following `PaywallScreen` patterns with Riverpod integration
- Integrated purchase flow into `ExportBottomSheet` - triggers when user has 0 credits
- Implemented restore purchases functionality for consumables
- Added legal compliance (Terms, Privacy links) matching existing paywall
- Credits are automatically added to balance after successful purchase

## Task Commits

Each task was committed atomically:

1. **Task 1: Create PurchaseButton widget** - `9e55ec4` (feat)
2. **Task 2: Create PurchaseCreditScreen** - `faaa6f9` (feat)
3. **Task 3: Integrate with ExportBottomSheet** - `1ea350f` (feat)

## Files Created/Modified

- `lib/widgets/purchase_button.dart` - Reusable purchase button with price, loading, and error states
- `lib/screens/purchase_credit_screen.dart` - Full purchase screen with Riverpod, restore, and legal links
- `lib/widgets/export_bottom_sheet.dart` - Updated to use PurchaseCreditScreen instead of ExportPurchaseSheet

## Decisions Made

- **Reusable PurchaseButton**: Created as separate widget for consistency across purchase flows
- **ConsumerStatefulWidget pattern**: Matched PaywallScreen implementation for consistency
- **Kept ExportPurchaseSheet**: Did not delete the existing ExportPurchaseSheet widget - it's still functional and could be used elsewhere
- **Price display**: Price shown in badge format next to button label for clarity

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## Next Phase Readiness

- Purchase flow is complete and ready for testing
- Checkpoint (Task 4) requires manual verification of purchase flow
- Ready for Phase 21: Settings Enhancement after checkpoint approval

---
*Phase: 20-per-export-pricing*
*Completed: 2026-02-07*
