---
phase: 20-per-export-pricing
plan: 04
type: execute
subsystem: ui
tags: [flutter, riverpod, bottom-sheet, credits, export]

# Dependency graph
requires:
  - phase: 20-per-export-pricing
    plan: 03
    provides: CreditsProvider with realtime subscription
provides:
  - CreditIndicator reusable widget
  - ExportBottomSheet with credit check and consumption
  - Per-export pricing UI flow
affects:
  - 20-05-PLAN (Purchase flow UI and integration)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "CreditIndicator: Reusable widget with multiple variants"
    - "Export flow: Check credits → consume → export"
    - "Pro user bypass: Subscription overrides credit system"

key-files:
  created:
    - lib/widgets/credit_indicator.dart
  modified:
    - lib/widgets/export_bottom_sheet.dart

key-decisions:
  - "Pro users export unlimited without consuming credits"
  - "Credit consumption happens at export time, not purchase"
  - "Purchase prompt shown when credits = 0 for non-Pro users"

patterns-established:
  - "CreditIndicator variants: compact (icon+count), expanded (+label)"
  - "Visual feedback: Low credits warning, zero credits error state"
  - "Bottom sheet integration: Credit balance visible in header"

issues-created: []

# Metrics
duration: 20min
completed: 2026-02-07
---

# Phase 20 Plan 04: Export Bottom Sheet with Credit Check Summary

**Export bottom sheet integrated with CreditsProvider showing credit balance, consuming credits on export, and prompting purchase when credits are zero for non-Pro users.**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-02-07T00:20:00Z
- **Completed:** 2026-02-07T00:40:00Z
- **Tasks:** 2/2
- **Files created:** 1
- **Files modified:** 1

## Accomplishments

- Created CreditIndicator reusable widget with:
  - Compact and expanded display variants
  - Visual states: loading, zero credits (red), low credits (≤2, orange), normal
  - Optional "Get Credits" button when credits = 0
  - Theme-aware styling following design system

- Updated ExportBottomSheet with CreditsProvider integration:
  - Credit indicator visible in header for non-Pro users
  - Credit check before export initiation
  - Credit consumption atomically tied to export start
  - Purchase prompt shown when credits = 0
  - Pro users bypass credit system entirely (unlimited exports)

## Task Commits

Each task was committed atomically:

1. **Task 1: CreditIndicator widget** - Part of `956c872` (feat)
2. **Task 2: ExportBottomSheet integration** - Part of `956c872` (feat)

**Plan metadata:** [pending - will be committed after summary creation]

## Files Created/Modified

- `lib/widgets/credit_indicator.dart` (new) - Reusable credit balance indicator
- `lib/widgets/export_bottom_sheet.dart` (modified) - Integrated with CreditsProvider

## Decisions Made

- Pro subscription takes precedence: Pro users never see credit UI or consume credits
- Credit consumption happens at export time (not at purchase), matching business logic
- Credit indicator uses color coding: red (0), orange (1-2), normal (3+)
- Compact variant for app bars/badges, expanded for detailed views

## Deviations from Plan

None - plan executed exactly as written. Files already existed from Phase 16, updated to integrate with CreditsProvider.

## Issues Encountered

None

## Next Phase Readiness

- CreditIndicator ready for use throughout app (app bars, settings, etc.)
- ExportBottomSheet fully functional with per-export pricing
- Ready for plan 20-05: Purchase flow UI and integration

---
*Phase: 20-per-export-pricing*
*Completed: 2026-02-07*
