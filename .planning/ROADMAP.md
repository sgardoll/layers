# Roadmap: Layers

## Milestones

- [v1.2 Critical Fixes](milestones/v1.2-critical-fixes.md) (Phase 15) — SHIPPED 2026-01-26
- [v1.1 Polish](milestones/v1.1-ROADMAP.md) (Phases 13-14) — SHIPPED 2026-01-26
- [v1.0 MVP](milestones/v1.0-ROADMAP.md) (Phases 1-12) — SHIPPED 2026-01-25

## Overview

Build a Flutter app that transforms images into editable layer stacks via AI inference. Start with foundation and architecture, integrate cloud GPU backend for Qwen model, build the signature 3D viewer experience, add export/persistence, then ship with freemium monetization across all platforms.

## Completed Phases

<details>
<summary>v1.0 MVP (Phases 1-12) — SHIPPED 2026-01-25</summary>

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 2/2 | Complete | 2026-01-23 |
| 2. Backend & API | 2/2 | Complete | 2026-01-23 |
| 2.1 Supabase + BuildShip | 3/3 | Complete | 2026-01-23 |
| 3. Core Experience | 3/3 | Complete | 2026-01-23 |
| 4. Export & Persistence | 3/3 | Complete | 2026-01-24 |
| 5. Monetization & Launch | 3/3 | Complete | 2026-01-24 |
| 6. Email Auth & RevenueCat | 1/1 | Complete | 2026-01-24 |
| 7. BuildShip Backend JSON | 1/1 | Complete | 2026-01-24 |
| 8. Bug Fixes & Refinement | 1/1 | Complete | 2026-01-24 |
| 9. BuildShip Workflow Spec | 1/1 | Complete | 2026-01-24 |
| 10. Account Delete Cleanup | 1/1 | Complete | 2026-01-25 |
| 11. App Icon Theme | 1/1 | Complete | 2026-01-25 |
| 12. macOS App Store | 1/1 | Complete | 2026-01-25 |

</details>

## Completed Milestones

<details>
<summary>v1.1 Polish & Verification (Phases 13-14) — SHIPPED 2026-01-26</summary>

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 13. App Flow Verification | 1/1 | Complete | 2026-01-26 |
| 14. Remove Layers from App Bar | 1/1 | Complete | 2026-01-26 |

**Key Changes:**
- Fixed 3D layer viewer (perspective must be on same Transform as Z-translation)
- Fixed LayersScreen to auto-fetch layers from Supabase on mount
- Fixed bundle IDs to com.connectio.layers across all platforms
- Removed Layers tab from navigation (3-tab layout: Projects, Exports, Settings)

</details>

## Current Milestone

### 🚧 v1.2.1 Critical Bug Fix: Anonymous RLS (In Progress)

**Milestone Goal:** Fix Supabase RLS policies to allow non-logged-in users to create projects

| Phase | Description | Status | Completed |
|-------|-------------|--------|-----------|
| 15.1 | Anonymous RLS Fix | Ready | - |
| 15.2 | App Store Review Compliance | Complete | 2026-02-01 |
| 15.3 | Mac App Store Compliance | Complete | 2026-02-01 |

#### Phase 15.1: Anonymous RLS Fix

**Goal:** Update RLS policies to support anonymous (non-logged-in) project creation
**Depends on:** Phase 15 (Critical Bug Fixes baseline)
**Research:** Not needed (schema.sql already has correct policies)
**Plans:** 1 plan ready

Plans:
- [x] 15.1-01: Update RLS migration and add storage policies

#### Phase 15.2: App Store Review Compliance

**Goal:** Address App Store Review feedback for Guideline 3.1.2 - Subscriptions compliance
**Depends on:** Phase 15.1
**Research:** Not needed - using url_launcher approach
**Plans:** 1 plan ready

**Review Feedback:**
- Missing required subscription information in purchase flow
- Missing Terms of Use (EULA) link in App Store metadata
- Missing privacy policy link in App Store metadata

**Required in app:**
- Title of auto-renewing subscription ✅
- Length of subscription ✅
- Price of subscription (and per unit if appropriate) ✅
- Functional links to privacy policy and Terms of Use (EULA) - **To implement**

**Required in metadata:**
- Privacy policy link in Privacy Policy field - **Manual**
- Terms of Use (EULA) in App Description or EULA field - **Manual**

Plans:
- [x] 15.2-01: Add legal links and documents for App Store compliance

#### Phase 15.3: Mac App Store Compliance

**Goal:** Address Mac App Store Review feedback for multiple guidelines
**Depends on:** Phase 15.2
**Research:** Not needed - straightforward fixes
**Plans:** 1 plan ready

**Review Feedback:**

**Guideline 4.3 - Design (Spam):**
- App icon is identical to other apps in the App Store
- Must revise to ensure uniqueness

**Guideline 2.4.5(i) - Performance (Entitlements):**
- Unused entitlement: `com.apple.security.files.downloads.read-write`
- Must explain usage or remove from entitlements
- Requires Developer Reject and new binary if removing

**Guideline 3.1.2 - Business/Payments/Subscriptions:**
- Missing subscription information in purchase flow ✅ (handled in 15.2)
- Missing Terms of Use (EULA) link ✅ (handled in 15.2)
- Missing privacy policy link ✅ (handled in 15.2)

Plans:
- [x] 15.3-01: Remove unused entitlements and redesign app icon

---

### 🚧 v1.3 Monetization & Settings (Current Milestone)

**Milestone Goal:** Add per-export consumable IAP and improve settings screen with user info, subscription status, and account management

**Requirements:** 18 total (MON-01 to MON-06, SET-01 to SET-06, DB-01 to DB-04, STATE-01 to STATE-03)

| Phase | Description | Status | Completed |
|-------|-------------|--------|-----------|
| 20 | Per-Export Pricing | Complete | 2026-02-07 |
| 21 | Settings Enhancement | Ready | - |

---

#### Phase 20: Per-Export Pricing — **COMPLETE** ✓

**Completed:** 2026-02-07

**Goal:** Add $0.50 consumable IAP as additional monetization option alongside subscriptions, with monthly bonus credits for Pro users

**Depends on:** Phase 19 (RevenueCat already integrated)
**Research:** Completed — see `.planning/research/`
**Requirements:** MON-01 to MON-06, DB-01, DB-02, DB-04, STATE-01, STATE-03

**Success Criteria:** ✓ All met
1. ✓ User can purchase single export credit for $0.50
2. ✓ Credit is consumed at moment of export (not purchase)
3. ✓ Pro subscribers receive bonus credits monthly
4. ✓ Clear price display with configure-before-pay flow
5. ✓ Restore purchases works for both subscriptions and consumables

**Key Implementation Notes:**
- Configure consumable product in RevenueCat dashboard ($0.49/0.50)
- Create `user_credits` table with RLS policies
- Create `purchase_transactions` table for idempotency
- Fix `projects.user_id` FK from SET NULL to CASCADE
- Build `CreditsProvider` following existing `entitlement_provider.dart` pattern
- Add realtime subscription for credit updates
- Test consumable repurchase on Android (known platform issue)

Plans:
- [x] 20-01: Database migrations (user_credits, purchase_transactions)
- [x] 20-02: CreditsProvider and realtime subscription
- [x] 20-03: RevenueCat consumable configuration
- [x] 20-04: Export bottom sheet with credit check/consume logic
- [x] 20-05: Purchase flow UI and integration

---

#### Phase 21: Settings Enhancement

**Goal:** Display user info, subscription status, usage stats, and implement full account deletion with data cleanup

**Depends on:** Phase 20
**Research:** Completed — see `.planning/research/`
**Requirements:** SET-01 to SET-06, DB-03, STATE-02

**Success Criteria:**
1. Settings displays current user email address
2. Settings shows subscription status (Free/Pro)
3. Settings displays export statistics (total exports, credits remaining)
4. "Manage Subscription" button deep-links to platform settings
5. "Delete Account" option with confirmation flow
6. Account deletion performs full data cleanup (projects, layers, exports, storage)

**Key Implementation Notes:**
- Create `delete_user_account` Edge Function (not RPC) for secure cascade deletion
- Build `StatsProvider` for aggregating user statistics
- Storage cleanup must happen BEFORE auth user deletion (not CASCADE)
- Always call `RevenueCat.logOut()` before account deletion
- Use `security definer` with `auth.uid()` validation
- Test deletion end-to-end with orphaned data verification

Plans:
- [ ] 21-01: StatsProvider for user statistics
- [ ] 21-02: Enhanced SettingsScreen with user info section
- [ ] 21-03: Delete account Edge Function with cascade cleanup
- [ ] 21-04: Account deletion UI flow with confirmation
- [ ] 21-05: Testing and verification

---

### 🎨 v1.4 Visual Overhaul (Next Priority)

**Milestone Goal:** Transform the generic aesthetic into a distinctive, clean, light, and airy design system while fixing the mobile portrait UX issue.

**Design Direction:** Clean, light, airy with generous whitespace — refined minimalism like a pro creative tool

| Phase | Description | Status | Completed |
|-------|-------------|--------|-----------|
| 18 | Design System Foundation | **Complete** | 2026-02-05 |
| 19 | Mobile UX & Layout | **Complete** | 2026-02-05 |

See: [v1.4-visual-overhaul.md](milestones/v1.4-visual-overhaul.md)

---

## Backlog

| Feature | Description |
|---------|-------------|
| Web platform | Flutter web deployment |
| .layers export | Custom export format |
| Visual overhaul | v1.4 milestone created |

## Domain Expertise

None
