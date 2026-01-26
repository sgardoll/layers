# Current State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-25)

**Core value:** The 3D layer viewer must feel magical
**Current focus:** v1.0 shipped — planning next milestone

## Current Position

Phase: v1.1 Complete
Plan: N/A
Status: v1.2 planning
Last activity: 2026-01-26 — v1.1.1 build 9 deployed to all stores

Progress: Milestone complete — ready for v1.2

## Shipped Builds

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

### Blockers
None
