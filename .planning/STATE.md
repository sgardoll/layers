# Current State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-25)

**Core value:** The 3D layer viewer must feel magical
**Current focus:** v1.3 Monetization & Settings

## Current Position

Phase: 19-mobile-ux
Plan: 19-01-PLAN.md
Status: Complete

Last activity: 2026-02-05 — Phase 19-01 complete: Responsive layout with 3-tab navigation

Progress: Mobile UX complete — responsive layout, 3-tab navigation (3D/2D/Layers), bottom sheet on mobile

Progress Bar: █████████████████████░░░ 84% (Phases 1-19 complete)

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

1. Test end-to-end flow: create project → BuildShip processes → app shows layers
2. Plan v1.1 features (web platform, .layers export, user feedback)

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

### Completed This Session
- Responsive layout system (Phase 19-01)
  - Breakpoints: mobile (<600px), tablet (600-900px), desktop (>900px)
  - ResponsiveLayout widget with builder pattern
  - LayerListPanel now theme-aware (uses AppColors)
  - LayersScreen adapts: side panel on desktop, bottom sheet on mobile
  - Mobile portrait: Full 3D viewer with bottom sheet for layers
  - 3-tab navigation (3D/2D/Layers) in unified control
  - Checkpoint issues fixed and verified
- Design system foundation complete (Phase 18-01)
  - Dual color palettes: Light (clean blue/cyan) and Dark (immersive navy with cyan glow)
  - Typography system using Inter font via Google Fonts
  - Spacing tokens (4-64pt scale) with EdgeInsets helpers
  - Complete ThemeData for both light and dark modes
  - Integrated into main.dart, app builds successfully
- BuildShip workflow fully implemented (triggers on project insert, extracts layers, uploads to storage)
- Fixed LayersScreen to auto-fetch layers from Supabase on mount

### Open Items
- End-to-end testing needed
- RevenueCat: Create `export_single` consumable product ($0.50) in dashboard

### Pending Todos
- Fix missing `delete_user_account` RPC function in Supabase (see .planning/todos/pending/)

### Roadmap Evolution
- Phase 14 added: Remove "Layers" from app bar - access via Project/Export tabs
- Phase 15 complete: Critical Bug Fixes - all issues resolved
- Phase 15.2 added: App Store Review Compliance (iOS subscriptions/EULA)
- Phase 15.3 added: Mac App Store Compliance (icon, entitlements, subscriptions)

### Phase 15 Fixes (2026-01-26)
- iOS image picker: Use XFile.readAsBytes() for sandboxing compatibility
- Image thumbnails: Use signed URLs instead of public URLs
- RevenueCat: Pass initialized instance to ProviderScope
- Status badge overflow: Flexible wrapper with ellipsis
- Export compliance: Added ITSAppUsesNonExemptEncryption to Info.plist

### Phase 18 Complete (2026-02-05)
- Design system foundation with dual themes
- Files: lib/theme/app_colors.dart, app_spacing.dart, app_typography.dart, app_theme.dart
- Commits: 23b116d, edffc73

### Phase 19 Complete (2026-02-05)
- Responsive layout system created
- LayerListPanel updated with theme-aware colors and optional header
- LayersScreen refactored with mobile bottom sheet
- 3-tab navigation (3D/2D/Layers) replaces toggle + button
- Checkpoint issues fixed: duplicate header removed
- Commits: dab16d9, 970fe6a, 42a736e

### Quick Tasks Completed

| # | Description | Date | Commit |
|---|-------------|------|--------|
| 001 | Fix entitlement state persistence on logout | 2026-02-01 | 1f6210b |
| 004 | Fix Dart syntax errors in 3D layer viewer | 2026-02-04 | 67f3377 |

### Blockers
None
