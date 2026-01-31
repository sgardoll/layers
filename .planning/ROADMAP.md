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
| 15.1 | Anonymous RLS Fix | Planned | - |
| 15.2 | App Store Review Compliance | Not Started | - |
| 15.3 | Mac App Store Compliance | Not Started | - |

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
**Research:** Needed - app icon design, entitlements review
**Plans:** TBD

**Review Feedback:**

**Guideline 4.3 - Design (Spam):**
- App icon is identical to other apps in the App Store
- Must revise to ensure uniqueness

**Guideline 2.4.5(i) - Performance (Entitlements):**
- Unused entitlement: `com.apple.security.files.downloads.read-write`
- Must explain usage or remove from entitlements
- Requires Developer Reject and new binary if removing

**Guideline 3.1.2 - Business/Payments/Subscriptions:**
- Missing subscription information in purchase flow (same as iOS)
- Missing Terms of Use (EULA) link
- Missing privacy policy link

Plans:
- [ ] 15.3-01: TBD (run /gsd-plan-phase 15.3 to break down)

---

### 🚧 v1.3 Monetization & Settings (Up Next)

**Milestone Goal:** Add per-export consumable IAP and improve settings screen with user info, subscription status, and account management

| Phase | Description | Status | Completed |
|-------|-------------|--------|-----------|
| 16 | Per-Export Pricing | Not Started | - |
| 17 | Settings Screen | Not Started | - |

---

#### Phase 16: Per-Export Pricing

**Goal:** Add $0.50 consumable IAP as additional monetization option alongside subscriptions
**Depends on:** Phase 15 (RevenueCat already integrated)
**Research:** Unlikely (RevenueCat patterns established)
**Plans:** TBD

Plans:
- [ ] 16-01: TBD (run /gsd-plan-phase 16 to break down)

#### Phase 17: Settings Screen

**Goal:** Display user info, subscription status, usage stats, and add delete account functionality
**Depends on:** Phase 16
**Research:** Unlikely (internal patterns)
**Plans:** TBD

Plans:
- [ ] 17-01: TBD (run /gsd-plan-phase 17 to break down)

---

## Backlog

| Feature | Description |
|---------|-------------|
| Web platform | Flutter web deployment |
| .layers export | Custom export format |

## Domain Expertise

None
