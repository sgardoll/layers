# Architecture

**Analysis Date:** 2026-02-04

## Pattern Overview

**Overall:** Feature-First Layered Architecture with Riverpod State Management

**Key Characteristics:**
- Single codebase for iOS, Android, macOS, and web
- Declarative UI with Flutter widget tree
- Reactive state management via Riverpod providers
- Service-oriented backend communication
- Immutable data models

## Layers

**Presentation Layer (UI):**
- Purpose: Render UI and handle user interactions
- Contains: Screens (`lib/screens/`), Widgets (`lib/widgets/`)
- Location: `lib/screens/`, `lib/widgets/`
- Depends on: State layer (Riverpod providers)
- Used by: Flutter framework

**State Layer:**
- Purpose: Manage application state and business logic
- Contains: Riverpod providers, notifiers
- Location: `lib/providers/`
- Key files: `lib/providers/auth_provider.dart`, `lib/providers/project_provider.dart`, `lib/providers/layer_provider.dart`, `lib/providers/entitlement_provider.dart`
- Depends on: Service layer
- Used by: Presentation layer

**Service Layer:**
- Purpose: Encapsulate external communication and domain logic
- Contains: Service classes for Supabase, RevenueCat, exports
- Location: `lib/services/`
- Key files: `lib/services/auth_service.dart`, `lib/services/revenuecat_service.dart`, `lib/services/supabase_project_service.dart`, `lib/services/supabase_export_service.dart`
- Depends on: Core/infrastructure layer
- Used by: State layer

**Core/Infrastructure Layer:**
- Purpose: Low-level abstractions and external client configuration
- Contains: Supabase client, API clients, result types
- Location: `lib/core/`
- Key files: `lib/core/supabase_client.dart`, `lib/core/api_client.dart`, `lib/core/result.dart`
- Depends on: External SDKs only
- Used by: Service layer

**Data/Model Layer:**
- Purpose: Define data structures
- Contains: Immutable model classes
- Location: `lib/models/`
- Key files: `lib/models/project.dart`, `lib/models/layer.dart`
- Depends on: Nothing (pure data)
- Used by: All other layers

## Data Flow

**App Initialization:**

1. `main()` called - `lib/main.dart`
2. Initialize Flutter bindings
3. Initialize Supabase (`initSupabase()` in `lib/core/supabase_client.dart`)
4. Initialize RevenueCat (`RevenueCatService.initialize()`)
5. Run app with `ProviderScope`
6. Router initializes and navigates to initial route (`/project`)

**Authentication Flow:**

1. User enters credentials on `AuthScreen`
2. Form submits to `AuthStateNotifier` (`lib/providers/auth_provider.dart`)
3. `AuthStateNotifier` calls `AuthService.signIn/signUp`
4. `AuthService` uses Supabase Auth SDK
5. Auth state change streamed via `authStateStreamProvider`
6. UI reacts to state changes automatically

**Project Creation Flow:**

1. User selects image in `ProjectScreen`
2. Image uploaded to Supabase Storage
3. Project record created in Supabase database
4. BuildShip workflow triggered (planned) for AI processing
5. Processing status updated via Realtime
6. Layers displayed in `LayerSpaceView`

**Purchase Flow:**

1. User taps upgrade/purchase in `PaywallScreen` or `ExportPurchaseSheet`
2. `RevenueCatService.purchasePackage()` called
3. RevenueCat SDK handles native purchase flow
4. On success, entitlements updated
5. `entitlementProvider` reflects new state
6. UI updates to reflect Pro status

**State Management:**
- Stateless - no persistent in-memory state across app restarts
- State reconstructed from Supabase on app launch
- Realtime subscriptions keep UI in sync with backend

## Key Abstractions

**Provider (Riverpod):**
- Purpose: Reactive state container
- Examples: `authServiceProvider`, `currentUserProvider`, `projectProvider`, `cameraProvider`
- Pattern: Functional providers, StateNotifier for mutable state
- Location: `lib/providers/`

**Service:**
- Purpose: Encapsulate external API communication
- Examples: `AuthService`, `RevenueCatService`, `SupabaseProjectService`
- Pattern: Class-based with dependency injection via constructor
- Location: `lib/services/`

**Model:**
- Purpose: Immutable data structures with serialization
- Examples: `Project`, `Layer`, `LayerTransform`, `LayerBbox`
- Pattern: Manual immutable classes with `copyWith`, `fromJson`, `toJson`
- Note: Intentionally NOT using Freezed for core models (per comment in `lib/models/project.dart`)
- Location: `lib/models/`

**Screen:**
- Purpose: Full-page view
- Examples: `ProjectScreen`, `ExportScreen`, `SettingsScreen`, `AuthScreen`
- Pattern: ConsumerWidget or ConsumerStatefulWidget
- Location: `lib/screens/`

**Router:**
- Purpose: Navigation management
- Implementation: GoRouter with StatefulShellRoute for bottom nav
- Location: `lib/router/app_router.dart`

## Entry Points

**App Entry:**
- Location: `lib/main.dart`
- Triggers: App launch by OS
- Responsibilities: Initialize SDKs, setup Riverpod, configure router, run app

**Route Entry Points:**
- `/project` - `ProjectScreen` - Main project view
- `/exports` - `ExportScreen` - Export history
- `/settings` - `SettingsScreen` - App settings

## Error Handling

**Strategy:** Try-catch at service boundaries, propagate to UI via AsyncValue

**Patterns:**
- Services catch errors, log with `debugPrint`, rethrow
- State notifiers catch errors and update `AsyncValue.error` state
- UI uses `.when()` to handle loading/error/loaded states
- Example: `AuthStateNotifier` parses `AuthException` into user-friendly messages

## Cross-Cutting Concerns

**Logging:**
- `debugPrint` for debug output
- No structured logging framework
- Errors logged at service layer before rethrowing

**Validation:**
- Manual validation in UI forms
- Supabase RLS for database-level validation
- No centralized validation schema (Zod-like)

**Authentication:**
- Supabase Auth with email/password
- Session automatically managed by SDK
- Auth state exposed via `authStateStreamProvider`
- RevenueCat login links purchases to user ID

**Theming:**
- Material Design 3 with custom seed color (indigo)
- Light/dark mode support via `themeModeProvider`
- Theme applied at `MaterialApp.router` level

---

*Architecture analysis: 2026-02-04*
*Update when major patterns change*
