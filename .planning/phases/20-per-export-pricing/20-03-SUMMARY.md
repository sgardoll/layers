---
phase: 20-per-export-pricing
plan: 03
type: execute
subsystem: state-management
tags: [riverpod, realtime, supabase, credits]

# Dependency graph
requires:
  - phase: 20-per-export-pricing
    plan: 01
    provides: user_credits table schema
provides:
  - CreditTransaction model
  - CreditsService for Supabase operations
  - CreditsProvider with realtime updates
  - Optimistic UI for credit consumption
affects:
  - 20-04-PLAN (Export bottom sheet with credit check)
  - 20-05-PLAN (Purchase flow integration)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "StateNotifier with immutable CreditState following entitlement pattern"
    - "Realtime subscription with proper cleanup"
    - "Optimistic UI with rollback on failure"
    - "Derived providers for common queries"

key-files:
  created:
    - lib/providers/credits_provider.dart
  modified: []

key-decisions:
  - "Follow entitlement_provider.dart pattern exactly for consistency"
  - "Optimistic UI updates with rollback on consume failure"
  - "Derived providers (hasCredits, creditsRemaining) for common queries"

patterns-established:
  - "CreditState: Immutable state with copyWith, loading/error handling"
  - "CreditsNotifier: User change handling, realtime listener setup"
  - "Supabase realtime: subscribe on login, cleanup on logout/dispose"

issues-created: []

# Metrics
duration: 15min
completed: 2026-02-07
---

# Phase 20 Plan 03: CreditsProvider Summary

**CreditsProvider built with realtime subscription to user_credits table, following existing entitlement_provider.dart patterns with optimistic UI and rollback on failure.**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-02-07T00:05:00Z
- **Completed:** 2026-02-07T00:20:00Z
- **Tasks:** 3/3
- **Files created:** 1

## Accomplishments

- Verified CreditTransaction model exists with proper serialization (from prior work)
- Verified CreditsService exists with all required methods including realtime subscription
- Created CreditsProvider following entitlement_provider.dart pattern exactly:
  - CreditState immutable class with copyWith
  - StateNotifierProvider with dependencies declared
  - Realtime subscription setup with proper cleanup
  - Optimistic UI updates with rollback on consume failure
  - Derived providers for hasCredits and creditsRemaining queries

## Task Commits

Each task was committed atomically:

1. **Task 1: CreditTransaction model** - Already existed (verified)
2. **Task 2: CreditsService** - Already existed (verified)
3. **Task 3: CreditsProvider** - `a745d40` (feat)

**Plan metadata:** [pending - will be committed after summary creation]

## Files Created

- `lib/providers/credits_provider.dart` - Complete CreditsProvider with realtime subscription

## Decisions Made

- Followed entitlement_provider.dart pattern exactly for architectural consistency
- Implemented optimistic UI for credit consumption (updates immediately, rolls back on failure)
- Added derived providers (hasCreditsProvider, creditsRemainingProvider) for common UI queries
- Used proper Supabase realtime subscription with cleanup on logout and dispose

## Deviations from Plan

None - plan executed exactly as written. Tasks 1 and 2 were already complete from prior work.

## Issues Encountered

None

## Next Phase Readiness

- CreditsProvider ready for integration in export flow
- Realtime subscription will automatically update UI when credits change
- Optimistic consumeCredit() ready for export bottom sheet integration
- Ready for plan 20-04: Export bottom sheet with credit check/consume logic

---
*Phase: 20-per-export-pricing*
*Completed: 2026-02-07*
