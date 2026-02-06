# Current State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-06)

**Core value:** The 3D layer viewer must feel magical
**Current focus:** v1.3 Monetization & Settings

## Current Position

Milestone: v1.3 Monetization & Settings
Phase: Not started (defining requirements)
Plan: —
Status: Defining requirements

Last activity: 2026-02-07 — Completed quick task 006: Hide subscription row when logged out

## Shipped Builds

- v1.1.2 build 14 (2026-01-26):
  - iOS: TestFlight
  - Android: Play Store (build 14)
  - macOS: App Store Connect (build 13)
  
- v1.1.1 build 9 (2026-01-26):
  - iOS: TestFlight
  - Android: Play Store
  - macOS: App Store Connect

## Next Steps

1. Complete requirements definition for v1.3
2. Create roadmap for Phases 16-17
3. Begin Phase 16: Per-Export Pricing

## Accumulated Context

### Key Decisions (this milestone)
- Supabase + BuildShip replaced custom Dart backend
- fal.ai BiRefNet for AI layer extraction (via Wavespeed)
- Email auth with RevenueCat user linking
- Theme colors from app icon (#1C39EC, #00A9FE)
- Design system uses Inter font via Google Fonts for distinctive typography
- Dual theme system: Light (clean/airy) and Dark (immersive navy with cyan glow)
- Responsive breakpoint at 600px (Material Design standard)
- Bottom sheet pattern for mobile secondary UI (feels more natural than drawer)
- 3-tab navigation (3D/2D/Layers) for unified view control
- Optional component headers for flexible UI composition
- Riverpod provider dependencies must be declared when using ProviderScope overrides

### Validated Capabilities (Shipped)
- v1.0 MVP: Core layer extraction, 3D viewer, export, project management
- v1.1 Polish: App flow fixes, navigation improvements
- v1.2 Critical Fixes: Anonymous RLS, App Store compliance, macOS compliance
- v1.4 Visual Foundation: Design system, responsive layout, mobile UX

### Open Items
- v1.3 Monetization & Settings: Not started
- BuildShip workflow processing: Spec complete, needs implementation
- End-to-end testing needed

### Pending Todos
- Fix missing `delete_user_account` RPC function in Supabase (see .planning/todos/pending/)

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 001 | Fix entitlement state persistence on logout | 2026-02-01 | 1f6210b | - |
| 004 | Fix Dart syntax errors in 3D layer viewer | 2026-02-04 | 67f3377 | - |
| 005 | Fix Deploy for Mac OS | 2026-02-06 | 9a9544d | [005-fix-mac-os-deploy](./quick/005-fix-mac-os-deploy/) |
| 006 | Hide subscription row when logged out | 2026-02-06 | 118edb6 | [006-hide-subscription-row-when-logged-out](./quick/006-hide-subscription-row-when-logged-out/) |

### Blockers
None
