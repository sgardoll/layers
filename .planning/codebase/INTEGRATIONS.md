# External Integrations

**Analysis Date:** 2026-02-04

## APIs & External Services

**AI Layer Extraction:**
- fal.ai BiRefNet - Image segmentation for layer extraction
  - Integration method: REST API via BuildShip workflow (planned)
  - Auth: API key in `FAL_API_KEY` env var
  - Status: BuildShip workflow spec complete, implementation pending (see `.planning/phases/09-buildship-workflow-spec/SPEC.md`)

**Payment Processing:**
- RevenueCat - Subscription management and in-app purchases
  - SDK: `purchases_flutter` 9.10.7
  - Auth: Platform-specific API keys (`REVENUECAT_IOS_KEY`, `REVENUECAT_ANDROID_KEY`)
  - Implementation: `lib/services/revenuecat_service.dart`
  - Features: Pro subscriptions, export credit consumables
  - Entitlement: "Layers Pro"

## Data Storage

**Databases:**
- Supabase PostgreSQL - Primary data store
  - Connection: Via `supabase_flutter` SDK
  - Auth: `SUPABASE_URL` and `SUPABASE_ANON_KEY` env vars
  - Tables: `projects`, `project_layers`, `exports` (per PROJECT.md)
  - Realtime: Enabled for live updates
  - Client: `lib/core/supabase_client.dart`

**File Storage:**
- Supabase Storage - User uploads and layer exports
  - Buckets: Source images, processed layer PNGs
  - Auth: Same Supabase anon key
  - Client: Via `supabaseStorageProvider` in `lib/core/supabase_client.dart`

**Local Storage:**
- Shared Preferences - Settings and small data
  - Package: `shared_preferences` 2.3.5
  - Used for: Theme mode, user preferences

## Authentication & Identity

**Auth Provider:**
- Supabase Auth - Email/password authentication
  - Implementation: `lib/services/auth_service.dart`
  - Features: Sign up, sign in, sign out, password reset
  - Session: Managed by Supabase SDK with automatic token refresh
  - Provider: `lib/providers/auth_provider.dart`

**Identity Linking:**
- RevenueCat user linking - Purchases tied to Supabase user ID
  - Method: `RevenueCatService.logIn(userId)` called after auth
  - Ensures subscription persistence across devices

## Monitoring & Observability

**Error Tracking:**
- Flutter `debugPrint` - Basic logging only
  - No external error tracking service (Sentry, Crashlytics) currently integrated
  - Errors logged to console in debug mode

**Analytics:**
- None currently integrated

**Logs:**
- stdout/stderr via Flutter's print/debugPrint

## CI/CD & Deployment

**Hosting:**
- iOS/macOS: App Store Connect
- Android: Google Play Console
- Web: Planned (platform already configured in `web/`)

**CI Pipeline:**
- GitHub Actions - See `.github/workflows/` directory

## Environment Configuration

**Development:**
- Required env vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `REVENUECAT_IOS_KEY`, `REVENUECAT_ANDROID_KEY`
- Optional: `FAL_API_KEY` (for AI processing)
- Secrets location: `.env` file (gitignored)
- Example: `.env.example` documents required variables

**Staging:**
- Uses Supabase staging project (if configured)
- RevenueCat sandbox environment

**Production:**
- Supabase production project
- RevenueCat production environment
- App Store / Play Store release builds

## Webhooks & Callbacks

**Incoming:**
- None currently (all processing via direct SDK calls)

**Outgoing:**
- BuildShip workflow triggers (planned)
  - Trigger: Database events on `projects` table
  - Endpoint: BuildShip webhook URL
  - Events: New project created, processing state changes

## Third-Party Services Summary

| Service | Purpose | SDK/Client | Location |
|---------|---------|------------|----------|
| Supabase | Database, Auth, Storage | `supabase_flutter` | `lib/core/supabase_client.dart` |
| RevenueCat | Subscriptions | `purchases_flutter` | `lib/services/revenuecat_service.dart` |
| fal.ai | AI layer extraction | HTTP via BuildShip | Planned (`.planning/phases/09-buildship-workflow-spec/`) |

---

*Integration audit: 2026-02-04*
*Update when adding/removing external services*
