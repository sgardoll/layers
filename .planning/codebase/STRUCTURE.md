# Codebase Structure

**Analysis Date:** 2026-02-04

## Directory Layout

```
layers/
├── lib/                    # Dart source code
│   ├── core/              # Infrastructure (Supabase, API clients)
│   ├── custom_code/       # Custom actions/widgets (FlutterFlow legacy)
│   ├── models/            # Data models (Project, Layer)
│   ├── providers/         # Riverpod state providers
│   ├── router/            # GoRouter configuration
│   ├── screens/           # Full-page screens
│   ├── services/          # Business logic services
│   └── widgets/           # Reusable UI components
├── test/                  # Test files
├── ios/                   # iOS platform code
├── android/               # Android platform code
├── macos/                 # macOS platform code
├── web/                   # Web platform code
├── windows/               # Windows platform code
├── linux/                 # Linux platform code
├── supabase/              # Supabase migrations/config
├── buildship/             # BuildShip workflow specs
├── assets/                # Static assets (images, fonts)
├── .planning/             # Project planning documents
│   ├── codebase/          # This codebase documentation
│   ├── phases/            # Implementation phase specs
│   ├── PROJECT.md         # Project overview
│   └── ROADMAP.md         # Development roadmap
├── pubspec.yaml           # Dart dependencies
├── analysis_options.yaml  # Dart linting rules
└── .env.example           # Environment variable template
```

## Directory Purposes

**lib/core/:**
- Purpose: Low-level infrastructure and external client setup
- Contains: Supabase initialization, API clients, result types
- Key files: `supabase_client.dart`, `api_client.dart`, `result.dart`
- Subdirectories: None

**lib/custom_code/:**
- Purpose: Legacy FlutterFlow custom code structure
- Contains: `actions/`, `widgets/` subdirectories with index files
- Status: Minimal usage, mostly empty
- Subdirectories: `actions/`, `widgets/`

**lib/models/:**
- Purpose: Immutable data model definitions
- Contains: `Project`, `Layer`, `LayerTransform`, `LayerBbox` classes
- Key files: `project.dart`, `layer.dart`
- Pattern: Manual immutable classes with JSON serialization

**lib/providers/:**
- Purpose: Riverpod state management providers
- Contains: State providers, notifiers, stream providers
- Key files: `auth_provider.dart`, `project_provider.dart`, `layer_provider.dart`, `entitlement_provider.dart`, `camera_provider.dart`
- Pattern: One provider per domain concern

**lib/router/:**
- Purpose: Navigation configuration
- Contains: GoRouter setup with routes
- Key files: `app_router.dart`
- Pattern: StatefulShellRoute for bottom navigation

**lib/screens/:**
- Purpose: Full-page screen widgets
- Contains: Screen implementations for each route
- Key files: `project_screen.dart`, `export_screen.dart`, `settings_screen.dart`, `auth_screen.dart`, `paywall_screen.dart`, `layers_screen.dart`
- Pattern: ConsumerWidget or ConsumerStatefulWidget

**lib/services/:**
- Purpose: Business logic and external API communication
- Contains: Service classes for Supabase, RevenueCat, exports
- Key files: `auth_service.dart`, `revenuecat_service.dart`, `supabase_project_service.dart`, `supabase_export_service.dart`
- Pattern: Injectable service classes

**lib/widgets/:**
- Purpose: Reusable UI components
- Contains: Widgets used across multiple screens
- Key files: `layer_space_view.dart`, `layer_card_3d.dart`, `stack_view_2d.dart`, `app_shell.dart`, `export_bottom_sheet.dart`
- Pattern: ConsumerWidget for state-aware widgets

**test/:**
- Purpose: Test files
- Contains: `widget_test.dart` (minimal)
- Status: Very limited test coverage

**supabase/:**
- Purpose: Supabase configuration and migrations
- Contains: Database schema, functions, policies

**buildship/:**
- Purpose: BuildShip workflow specifications
- Contains: Workflow JSON specs for AI processing

**.planning/:**
- Purpose: Project planning and documentation
- Contains: Roadmaps, phase specs, codebase docs
- Key files: `PROJECT.md`, `ROADMAP.md`, `STATE.md`

## Key File Locations

**Entry Points:**
- `lib/main.dart` - App entry point

**Configuration:**
- `pubspec.yaml` - Dependencies and Flutter config
- `analysis_options.yaml` - Dart lint rules
- `.env` - Environment secrets (gitignored)
- `.env.example` - Environment template

**Core Logic:**
- `lib/core/supabase_client.dart` - Supabase initialization
- `lib/services/auth_service.dart` - Authentication logic
- `lib/services/revenuecat_service.dart` - Subscription management
- `lib/providers/auth_provider.dart` - Auth state management

**Models:**
- `lib/models/project.dart` - Project data model
- `lib/models/layer.dart` - Layer, LayerTransform, LayerBbox models

**UI:**
- `lib/router/app_router.dart` - Route definitions
- `lib/widgets/layer_space_view.dart` - 3D layer viewer (signature feature)
- `lib/screens/project_screen.dart` - Main project screen

**Testing:**
- `test/widget_test.dart` - Minimal widget test

## Naming Conventions

**Files:**
- `snake_case.dart` for all Dart files
- `*_provider.dart` for Riverpod providers
- `*_service.dart` for service classes
- `*_screen.dart` for screen widgets
- `*.g.dart` for generated files (excluded from analysis)
- `*.freezed.dart` for Freezed generated files

**Directories:**
- `snake_case` for all directories
- Plural names for collections: `providers/`, `services/`, `screens/`, `widgets/`

**Special Patterns:**
- `index.dart` for barrel exports (in `custom_code/`)
- `.gitkeep` in empty directories

## Where to Add New Code

**New Feature:**
- Models: `lib/models/` (if new data structures)
- Services: `lib/services/` (if external API calls)
- Providers: `lib/providers/` (if state management needed)
- Screens: `lib/screens/` (if new page)
- Widgets: `lib/widgets/` (if reusable component)

**New Screen:**
- Implementation: `lib/screens/{name}_screen.dart`
- Route: Add to `lib/router/app_router.dart`
- Navigation: Add to `AppShell` tabs if needed

**New Service:**
- Implementation: `lib/services/{name}_service.dart`
- Provider: Add provider in same file or `lib/providers/`

**New Model:**
- Implementation: `lib/models/{name}.dart`
- Pattern: Immutable class with `copyWith`, `fromJson`, `toJson`

**Utilities:**
- Shared helpers: `lib/core/` or new `lib/utils/`
- Extensions: Create `lib/extensions/` if needed

## Special Directories

**lib/custom_code/:**
- Purpose: Legacy FlutterFlow structure
- Source: Originally generated by FlutterFlow
- Committed: Yes (minimal content)
- Status: Can be removed if not needed

**Generated Files:**
- Pattern: `*.g.dart`, `*.freezed.dart`
- Source: Generated by `build_runner`
- Committed: No (in `.gitignore`)
- Regenerate: `flutter pub run build_runner build`

**Platform Directories (ios/, android/, macos/, web/, windows/, linux/):**
- Purpose: Platform-specific configuration and native code
- Source: Generated by Flutter, manually configured
- Committed: Yes

---

*Structure analysis: 2026-02-04*
*Update when directory structure changes*
