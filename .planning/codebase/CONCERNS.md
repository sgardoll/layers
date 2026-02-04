# Codebase Concerns

**Analysis Date:** 2026-02-04

## Tech Debt

**Minimal Test Coverage:**
- Issue: Only one default widget test exists; no unit tests for critical services
- Files: `test/widget_test.dart` (only test file)
- Why: Rapid development focus on shipping v1.0
- Impact: High risk of regressions, difficult to refactor safely
- Fix approach: Add unit tests for services, widget tests for critical UI

**TODO Comments in Production Code:**
- Issue: Debug/testing code marked with TODO still present
- Files: `lib/widgets/export_bottom_sheet.dart` (lines 61, 63)
- Content: `// TODO: Remove before release - forces purchase sheet for testing`
- Why: Development shortcuts not cleaned up
- Impact: Potential security/exposure of test code paths
- Fix approach: Remove TODO comments and associated debug code before next release

**Manual JSON Serialization:**
- Issue: Core models (Project, Layer) use manual `fromJson`/`toJson` instead of code generation
- Files: `lib/models/project.dart`, `lib/models/layer.dart`
- Why: "Intentionally implemented without code generation so the project can build reliably in environments where build runner outputs are not present" (per comment)
- Impact: More boilerplate, risk of serialization errors
- Fix approach: Consider adding build runner to CI or pre-commit to ensure .g.dart files exist

## Known Issues

**BuildShip Workflow Not Implemented:**
- Issue: AI layer extraction via BuildShip is specified but not implemented
- Files: `.planning/phases/09-buildship-workflow-spec/SPEC.md` (spec exists)
- Impact: Core AI feature not functional; app cannot process images into layers
- Root cause: BuildShip workflow nodes need manual setup
- Fix: Implement BuildShip workflow per SPEC.md

**Deprecated Backend Folder Removed:**
- Issue: PROJECT.md mentions old `backend/` folder with Dart Shelf backend
- Status: Directory does not exist (already cleaned up)
- Impact: None (already resolved)

## Security Considerations

**Environment Variables in .env.example:**
- Risk: `.env.example` contains what appears to be real Supabase credentials
- File: `.env.example`
- Content: `SUPABASE_URL=https://dbluxquekhkihatcjplz.supabase.co`
- Current mitigation: File is committed to repo
- Recommendations: Verify these are sandbox/development credentials only; rotate if they are production keys

**No Certificate Pinning:**
- Risk: API calls to Supabase and fal.ai could be intercepted
- Files: `lib/core/supabase_client.dart`, `lib/core/api_client.dart`
- Current mitigation: HTTPS used (standard)
- Recommendations: Consider certificate pinning for production security hardening

**Debug Print in Production:**
- Risk: Sensitive information could be logged via `debugPrint`
- Files: Multiple service files use `debugPrint` for errors
- Current mitigation: `debugPrint` is stripped in release builds
- Recommendations: Review all `debugPrint` statements to ensure no sensitive data

## Performance Bottlenecks

**No Identified Critical Bottlenecks:**
- The 3D layer viewer (`lib/widgets/layer_space_view.dart`) uses Transform widgets which are efficient
- Image caching via `cached_network_image` is configured
- No N+1 query patterns detected (Supabase queries are direct)

**Potential Concerns:**
- Large image processing happens server-side (fal.ai) not client-side
- Layer images loaded from network; could benefit from aggressive preloading

## Fragile Areas

**RevenueCat Integration:**
- File: `lib/services/revenuecat_service.dart`
- Why fragile: Platform-specific API key selection logic
- Common failures: Wrong key for platform, initialization order issues
- Safe modification: Test on both iOS and Android when changing
- Test coverage: No automated tests

**Supabase Realtime Dependencies:**
- Files: `lib/providers/project_provider.dart`, `lib/providers/layer_provider.dart`
- Why fragile: UI assumes Realtime updates work; falls back to manual refresh unclear
- Common failures: WebSocket connection issues, missed updates
- Safe modification: Add offline fallback states
- Test coverage: No integration tests

**3D Layer Viewer Gestures:**
- File: `lib/widgets/layer_space_view.dart`
- Why fragile: Complex gesture handling (scale, pan, rotate) with keyboard modifiers
- Common failures: Gesture conflicts, platform differences in touch handling
- Safe modification: Test on all target platforms (iOS, Android, macOS)
- Test coverage: No widget tests

## Scaling Limits

**Supabase Free Tier:**
- Current capacity: Project appears to use Supabase free tier
- Limit: Database size, connection limits, API rate limits
- Symptoms at limit: Slow queries, connection errors
- Scaling path: Upgrade to Supabase Pro plan

**RevenueCat Free Tier:**
- Current capacity: RevenueCat free tier for subscription management
- Limit: Monthly active users, revenue tracking limits
- Scaling path: Upgrade to RevenueCat paid plan

## Dependencies at Risk

**flutter_dotenv:**
- Risk: Unmaintained pattern (environment variables in mobile apps)
- Impact: Security best practice is to use native configuration or secure storage
- Migration plan: Consider migrating to platform-specific config or encrypted storage

** purchases_flutter:**
- Risk: RevenueCat SDK updates required for new store requirements
- Impact: App Store / Play Store policy changes may require SDK updates
- Mitigation: Keep SDK updated, monitor RevenueCat changelog

## Missing Critical Features

**AI Processing Implementation:**
- Problem: BuildShip workflow for fal.ai integration not implemented
- Current workaround: None (feature not functional)
- Blocks: Core value proposition (AI layer extraction)
- Implementation complexity: Medium (workflow exists, needs setup)
- Location: `.planning/phases/09-buildship-workflow-spec/SPEC.md`

**Comprehensive Test Suite:**
- Problem: No unit tests, no integration tests
- Current workaround: Manual testing
- Blocks: Safe refactoring, CI/CD confidence
- Implementation complexity: Medium (services need mocking setup)

**Web Platform Deployment:**
- Problem: Web platform configured but not deployed
- Current workaround: Not available
- Blocks: Web user access
- Implementation complexity: Low (Flutter web build + hosting)

## Test Coverage Gaps

**Authentication Flow:**
- What's not tested: Sign in, sign up, password reset, session persistence
- Risk: Auth bugs could lock users out
- Priority: High
- Difficulty to test: Medium (need Supabase mocking)
- Files: `lib/services/auth_service.dart`, `lib/providers/auth_provider.dart`

**Purchase Flow:**
- What's not tested: Subscription purchase, restore, entitlement checking
- Risk: Revenue loss from broken purchase flow
- Priority: High
- Difficulty to test: High (need RevenueCat sandbox environment)
- Files: `lib/services/revenuecat_service.dart`

**Project Operations:**
- What's not tested: Project CRUD, layer operations, export functionality
- Risk: Data loss, broken user workflows
- Priority: Medium
- Difficulty to test: Medium (need Supabase mocking)
- Files: `lib/services/supabase_project_service.dart`, `lib/services/supabase_export_service.dart`

**3D Layer Viewer:**
- What's not tested: Gesture handling, camera controls, layer selection
- Risk: Broken signature feature
- Priority: High (core differentiator)
- Difficulty to test: Medium (widget testing with gestures)
- Files: `lib/widgets/layer_space_view.dart`, `lib/widgets/layer_card_3d.dart`

---

*Concerns audit: 2026-02-04*
*Update as issues are fixed or new ones discovered*
