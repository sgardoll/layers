# Testing Patterns

**Analysis Date:** 2026-02-04

## Test Framework

**Runner:**
- Flutter Test - Built-in testing framework (`flutter_test` package)
- Config: Default Flutter test configuration
- Location: Tests in `test/` directory

**Assertion Library:**
- Flutter Test built-in matchers
- Matchers: `expect()`, `findsOneWidget`, `findsNothing`, `isTrue`, `isFalse`, `equals()`

**Run Commands:**
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart   # Single file
flutter test --coverage         # Coverage report
flutter test --watch            # Watch mode (if configured)
```

## Test File Organization

**Location:**
- `test/` directory at project root
- Only one test file exists: `test/widget_test.dart`

**Naming:**
- `*_test.dart` for test files (Flutter convention)

**Structure:**
```
test/
└── widget_test.dart          # Minimal widget test (default Flutter template)
```

**Status:**
- Very limited test coverage
- Only default Flutter widget test exists
- No unit tests for services
- No integration tests

## Test Structure

**Suite Organization:**
```dart
// Current pattern (from widget_test.dart)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layers/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LayersApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

**Patterns:**
- Standard Flutter widget test pattern
- Uses `testWidgets` for widget tests
- Uses `WidgetTester` for interaction simulation

## Mocking

**Framework:**
- Mockito 5.4.4 - Configured in `pubspec.yaml` dev_dependencies
- Not currently used (no test files use mocking)

**Patterns:**
- Can use `Mock` classes for service mocking
- Can use `when()`/`thenReturn()` for stubbing

**What to Mock (when tests are added):**
- Supabase client operations
- RevenueCat SDK calls
- File system operations
- Network requests

## Fixtures and Factories

**Test Data:**
- No fixture files exist
- No factory functions for test data
- Test data would be created inline when tests are written

**Location:**
- Could create `test/fixtures/` for shared test data
- Could create factory functions in test files

## Coverage

**Requirements:**
- No enforced coverage target
- No coverage tracking currently configured

**Configuration:**
- Can run `flutter test --coverage` to generate LCOV report
- Report generated in `coverage/lcov.info`

**View Coverage:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Types

**Unit Tests:**
- Status: None exist
- Should test: Services (`AuthService`, `RevenueCatService`), Model serialization
- Location: Would be `test/services/`, `test/models/`

**Widget Tests:**
- Status: One default test exists
- Should test: Screen widgets, complex UI components
- Location: `test/widget_test.dart` (exists), would add `test/widgets/`

**Integration Tests:**
- Status: None exist
- Should test: Full user flows (auth, project creation, export)
- Location: Would be `integration_test/`

**E2E Tests:**
- Status: None exist
- Could use: Flutter integration tests or external tools

## Common Patterns

**Async Testing:**
```dart
// Pattern to use when adding tests
await tester.pumpWidget(const MyWidget());
await tester.pumpAndSettle();  // Wait for animations

// For async operations
await tester.runAsync(() async {
  await someAsyncOperation();
});
```

**Widget Testing:**
```dart
// Pattern to use when adding tests
await tester.pumpWidget(
  ProviderScope(
    child: MaterialApp(home: MyScreen()),
  ),
);
expect(find.text('Expected Text'), findsOneWidget);
```

**Provider Testing:**
```dart
// Pattern to use when testing Riverpod providers
final container = ProviderContainer();
addTearDown(container.dispose);

final result = container.read(myProvider);
expect(result, expectedValue);
```

## Testing Gaps

**Critical Untested Areas:**
- `lib/services/auth_service.dart` - No unit tests
- `lib/services/revenuecat_service.dart` - No unit tests
- `lib/services/supabase_project_service.dart` - No unit tests
- `lib/services/supabase_export_service.dart` - No unit tests
- `lib/providers/` - No provider tests
- `lib/models/` - No serialization tests
- `lib/widgets/layer_space_view.dart` - No widget tests for signature feature

**Recommended Priority:**
1. Service unit tests (Auth, RevenueCat)
2. Model serialization tests
3. Widget tests for LayerSpaceView (critical feature)
4. Integration tests for purchase flow

## Testing Dependencies

**Dev Dependencies:**
- `flutter_test` - Testing framework
- `mockito` 5.4.4 - Mocking framework
- `build_runner` - Code generation (for Mockito)

---

*Testing analysis: 2026-02-04*
*Update when test patterns change*
