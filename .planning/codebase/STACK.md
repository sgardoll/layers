# Technology Stack

**Analysis Date:** 2026-02-04

## Languages

**Primary:**
- Dart 3.x - All application code (`lib/`)

**Secondary:**
- Swift/Kotlin/Objective-C/Java - Platform-specific native code (iOS/Android/macOS)
- C++ - Flutter engine bindings (`windows/flutter/`, `linux/flutter/`)
- Gradle/Groovy - Android build configuration (`android/app/build.gradle.kts`)

## Runtime

**Environment:**
- Flutter SDK 3.8.0+ (as specified in `pubspec.yaml`)
- Dart SDK 3.8.0+ (same constraint)
- Target platforms: iOS, Android, macOS, Web, Windows, Linux

**Package Manager:**
- `flutter pub` / `dart pub`
- Lockfile: `pubspec.lock` present

## Frameworks

**Core:**
- Flutter 3.x - UI framework
- Material Design 3 - Design system (`useMaterial3: true` in `lib/main.dart`)

**State Management:**
- Riverpod 2.6.1 - Reactive state management (`flutter_riverpod`)
- Riverpod Generator 2.6.2 - Code generation for providers

**Routing:**
- Go Router 14.6.2 - Declarative routing (`lib/router/app_router.dart`)

**Testing:**
- Flutter Test - Built-in widget/unit testing framework
- Mockito 5.4.4 - Mocking framework

**Build/Dev:**
- Build Runner 2.4.13 - Code generation orchestration
- Freezed 2.5.7 - Immutable data class generation
- JSON Serializable 6.9.0 - JSON serialization code generation

## Key Dependencies

**Critical:**
- `supabase_flutter` 2.12.0 - Backend (Auth, Database, Storage, Realtime) - `lib/core/supabase_client.dart`
- `purchases_flutter` 9.10.7 - RevenueCat SDK for subscriptions - `lib/services/revenuecat_service.dart`
- `flutter_riverpod` 2.6.1 - State management - throughout `lib/providers/`
- `go_router` 14.6.2 - Navigation - `lib/router/app_router.dart`

**Infrastructure:**
- `dio` 5.7.0 - HTTP client for API calls
- `image_picker` 1.1.2 - Image selection from camera/gallery
- `share_plus` 10.1.3 - System share sheet integration
- `path_provider` 2.1.5 - File system access
- `archive` 4.0.7 - ZIP file creation for exports
- `uuid` 4.5.1 - UUID generation
- `cached_network_image` 3.4.1 - Image caching
- `flutter_animate` 4.5.2 - Animation utilities

**Configuration:**
- `flutter_dotenv` 6.0.0 - Environment variable loading - `lib/core/supabase_client.dart`
- `shared_preferences` 2.3.5 - Local key-value storage

## Configuration

**Environment:**
- `.env` file for secrets (loaded via `flutter_dotenv`)
- Required env vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `REVENUECAT_IOS_KEY`, `REVENUECAT_ANDROID_KEY`
- `.env.example` present for documentation

**Build:**
- `analysis_options.yaml` - Dart linting rules (extends `package:flutter_lints/flutter.yaml`)
- `pubspec.yaml` - Dependencies and Flutter configuration
- Platform-specific configs in `ios/`, `android/`, `macos/`, `web/`, `windows/`, `linux/`

## Platform Requirements

**Development:**
- Flutter 3.8.0+
- Dart 3.8.0+
- Xcode 15+ (for iOS/macOS)
- Android Studio / SDK (for Android)
- Chrome (for web)

**Production:**
- iOS: App Store distribution
- Android: Play Store distribution
- macOS: App Store / Direct distribution
- Web: Static hosting (planned)

---

*Stack analysis: 2026-02-04*
*Update after major dependency changes*
