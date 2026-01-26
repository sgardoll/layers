# Current State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-25)

**Core value:** The 3D layer viewer must feel magical
**Current focus:** v1.0 shipped — planning next milestone

## Current Position

Phase: 15 of 15 (Critical Bug Fixes)
Plan: Complete
Status: v1.2 Phase 15 complete
Last activity: 2026-01-26 — v1.1.2 build 14 deployed to all stores

Progress: Phase 15 complete — all critical bugs fixed

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

### Completed This Session
- BuildShip workflow fully implemented (triggers on project insert, extracts layers, uploads to storage)
- Fixed LayersScreen to auto-fetch layers from Supabase on mount

### Open Items
- Old `backend/` folder can be deleted
- End-to-end testing needed

### Roadmap Evolution
- Phase 14 added: Remove "Layers" from app bar - access via Project/Export tabs
- Phase 15 complete: Critical Bug Fixes - all issues resolved

### Phase 15 Fixes (2026-01-26)
- iOS image picker: Use XFile.readAsBytes() for sandboxing compatibility
- Image thumbnails: Use signed URLs instead of public URLs
- RevenueCat: Pass initialized instance to ProviderScope
- Status badge overflow: Flexible wrapper with ellipsis
- Export compliance: Added ITSAppUsesNonExemptEncryption to Info.plist

### Blockers
None
