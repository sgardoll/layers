# Milestone Context

**Generated:** 2026-01-26
**Status:** Ready for /gsd-new-milestone

## Features to Build

- **Per-export pricing**: $0.50 consumable IAP as additional monetization option alongside existing subscriptions. Users can choose to pay per export instead of subscribing.

- **Settings screen enhancements**: 
  - Display logged-in user email/name
  - Show current subscription status (subscribed/not subscribed, plan type)
  - Show export count/usage statistics
  - Add "Delete Account" functionality (implement missing `deleteAllUserData` method in SupabaseProjectService and `clear` method in ProjectListNotifier)

## Scope

**Suggested name:** v1.3 Monetization & Settings
**Estimated phases:** 2
**Focus:** Add per-export consumable IAP and improve settings screen with user info, subscription status, and account management

## Phase Mapping

- Phase 16: Per-export pricing - RevenueCat consumable IAP setup, purchase flow, export gating
- Phase 17: Settings screen - User info display, subscription status, usage stats, delete account

## Constraints

- Must work alongside existing subscription model
- RevenueCat already integrated (from v1.2 fixes)
- Settings screen already exists but missing methods need implementation

## Additional Context

- `deleteAllUserData` method missing from SupabaseProjectService
- `clear` method missing from ProjectListNotifier  
- These cause LSP errors in settings_screen.dart currently

---

*This file is temporary. It will be deleted after /gsd-new-milestone creates the milestone.*
