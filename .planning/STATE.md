# Current State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-25)

**Core value:** The 3D layer viewer must feel magical
**Current focus:** v1.0 shipped — planning next milestone

## Current Position

Phase: Complete (12 of 12)
Plan: N/A
Status: v1.0 SHIPPED
Last activity: 2026-01-25 — v1.0 milestone complete

Progress: [============] 100% (23/23 plans)

## Shipped Builds

- Android: `~/Desktop/Layers-1.0.0-build7-signed.aab` (Play Store)
- macOS: `~/Desktop/Layers-1.0.0-build7.xcarchive` (App Store)
- iOS: `~/Desktop/Layers-1.0.0-build5.xcarchive` (TestFlight)

## Next Steps

1. Implement BuildShip workflow processing nodes (see `.planning/phases/09-buildship-workflow-spec/SPEC.md`)
2. Plan v1.1 milestone (web platform, .layers export, user feedback)

## Accumulated Context

### Key Decisions (this milestone)
- Supabase + BuildShip replaced custom Dart backend
- fal.ai BiRefNet for AI layer extraction
- Email auth with RevenueCat user linking
- Theme colors from app icon (#1C39EC, #00A9FE)

### Open Items
- BuildShip workflows have triggers but need processing nodes
- Old `backend/` folder can be deleted

### Blockers
None
