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

### 🚧 v1.3 Monetization & Settings (In Progress)

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
