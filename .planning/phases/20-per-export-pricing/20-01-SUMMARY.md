---
phase: 20-per-export-pricing
plan: 01
subsystem: database
tags: [supabase, postgresql, rls, migrations]

requires:
  - phase: 19-mobile-ux
    provides: RevenueCat integration foundation
provides:
  - user_credits table with RLS policies
  - purchase_transactions table for idempotency
  - Fixed projects FK cascade for proper data cleanup
affects:
  - 20-02 (CreditsProvider will use user_credits table)
  - 21-03 (Delete account will use CASCADE behavior)

tech-stack:
  added: []
  patterns:
    - "RLS policies following existing DROP IF EXISTS / CREATE pattern"
    - "updated_at trigger with idempotent function creation"
    - "Dynamic FK constraint discovery for migrations"

key-files:
  created:
    - supabase/migrations/20260207_add_user_credits.sql
    - supabase/migrations/20260207_add_purchase_transactions.sql
    - supabase/migrations/20260207_fix_projects_fk.sql
  modified: []

key-decisions:
  - "Service role policies included for documentation even though service role bypasses RLS"
  - "transaction_id TEXT with UNIQUE constraint instead of UUID for RevenueCat compatibility"
  - "Dynamic constraint discovery in FK migration handles unknown constraint names"

patterns-established:
  - "Migration files include DO blocks for dynamic SQL operations"
  - "Verification steps embedded in migrations for safety"

issues-created: []

duration: 5min
completed: 2026-02-07
---

# Phase 20 Plan 01: Database Migrations Summary

**Database schema for export credit system with user credits tracking and purchase transaction idempotency**

## Performance

- **Duration:** 5 min
- **Started:** 2026-02-07T01:42:00Z
- **Completed:** 2026-02-07T01:47:00Z
- **Tasks:** 3/3
- **Files modified:** 3

## Accomplishments

- Created user_credits table with credits_remaining, monthly_bonus_credits, and RLS policies
- Created purchase_transactions table with unique transaction_id constraint for RevenueCat webhook idempotency
- Fixed projects.user_id FK from ON DELETE SET NULL to ON DELETE CASCADE

## Task Commits

Each task was committed atomically:

1. **Task 1: Create user_credits table migration** - `d85decb` (feat)
2. **Task 2: Create purchase_transactions table migration** - `c768ab6` (feat)
3. **Task 3: Fix projects.user_id FK cascade** - `efbeb28` (feat)

**Plan metadata:** TBD (SUMMARY commit)

## Files Created/Modified

- `supabase/migrations/20260207_add_user_credits.sql` - User credits table with RLS and trigger
- `supabase/migrations/20260207_add_purchase_transactions.sql` - Purchase transactions for idempotency
- `supabase/migrations/20260207_fix_projects_fk.sql` - Fixed FK cascade from SET NULL to CASCADE

## Decisions Made

- Followed existing migration patterns from 20260124_add_rls_policies.sql for consistency
- Used idempotent DROP POLICY IF EXISTS / CREATE POLICY pattern
- Included service role policies for documentation clarity
- Dynamic FK constraint discovery handles unknown constraint names safely

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Next Phase Readiness

- Database schema ready for 20-02 (CreditsProvider implementation)
- user_credits table has all required columns per DB-01
- purchase_transactions has transaction_id unique constraint per DB-02
- projects FK properly configured for account deletion cleanup

---
*Phase: 20-per-export-pricing*
*Completed: 2026-02-07*
