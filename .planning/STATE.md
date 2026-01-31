# Current State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-25)

**Core value:** The 3D layer viewer must feel magical
**Current focus:** v1.3 Monetization & Settings

## Current Position

Phase: 15.2 (App Store Review Compliance)
Plan: 15.2-01 complete
Status: Phase complete - Legal documents and links implemented

Phase: 15.3 (Mac App Store Compliance)
Plan: 15.3-01 complete
Status: Phase complete - Unused entitlement removed, new app icons deployed

Last activity: 2026-02-01 — Completed 15.3-01: Mac App Store compliance - entitlement fix and new app icons

Progress: ██████████ 100% (9/9 plans complete - Milestone v1.2.1 ready for submission)

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
- Legal documents hosted at https://layers-app.com (privacy-policy.html, terms-of-use.html)
- Legal links open in external browser with app-themed styling

### Completed This Session
- BuildShip workflow fully implemented (triggers on project insert, extracts layers, uploads to storage)
- Fixed LayersScreen to auto-fetch layers from Supabase on mount
- **Phase 15.2-01 complete**: Privacy Policy, Terms of Use (EULA), legal links in paywall and export sheet
- **Phase 15.3-01 complete**: Removed unused macOS entitlement, updated app icons for iOS/Android/macOS

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

### Blockers
None
