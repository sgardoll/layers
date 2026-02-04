# Coding Conventions

**Analysis Date:** 2026-02-04

## Naming Patterns

**Files:**
- `snake_case.dart` for all Dart files
- `*_provider.dart` for Riverpod providers
- `*_service.dart` for service classes
- `*_screen.dart` for screen widgets
- `*.g.dart` for generated files (excluded from linting)
- `*.freezed.dart` for Freezed generated files

**Classes:**
- `PascalCase` for all class names
- Examples: `AuthService`, `ProjectScreen`, `LayerTransform`

**Functions/Methods:**
- `camelCase` for all functions and methods
- Examples: `signIn()`, `getCustomerInfo()`, `copyWith()`
- Async functions: No special prefix (just `Future<T>` return type)
- Private methods: `_camelCase` with underscore prefix

**Variables:**
- `camelCase` for variables
- `lowerCamelCase` for constants within functions
- `UPPER_SNAKE_CASE` for top-level constants (rarely used)
- Private fields: `_camelCase` with underscore prefix

**Types:**
- `PascalCase` for type names (classes, typedefs)
- Generic type parameters: `T`, `K`, `V` (single letters) or descriptive names

## Code Style

**Formatting:**
- Dart `dart format` (standard Flutter formatting)
- Line length: 80 characters (Dart default)
- Indentation: 2 spaces

**Linting:**
- Tool: `flutter_lints` package (standard Flutter lint rules)
- Config: `analysis_options.yaml`
- Custom rules:
  - `prefer_single_quotes: true`
  - `always_declare_return_types: true`
  - `avoid_print: true`
  - `prefer_const_constructors: true`
  - `prefer_const_declarations: true`
  - `prefer_final_fields: true`
  - `prefer_final_locals: true`
  - `use_key_in_widget_constructors: true`
- Excludes: `**/*.g.dart`, `**/*.freezed.dart`

**Quotes:**
- Single quotes preferred (`'string'`)
- Double quotes allowed for strings containing single quotes

**Semicolons:**
- Required (Dart language requirement)

## Import Organization

**Order:**
1. Dart SDK imports (`dart:*`)
2. Flutter SDK imports (`package:flutter/*`)
3. Third-party package imports (`package:*/`)
4. Relative imports (`../`, `./`)

**Grouping:**
- Blank line between groups
- Alphabetical within each group (roughly)

**Example:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layer.dart';
import '../providers/camera_provider.dart';
import 'layer_card_3d.dart';
```

**Path Aliases:**
- None defined (uses relative imports)

## Error Handling

**Patterns:**
- Try-catch at service boundaries
- Rethrow after logging for upstream handling
- Use `AsyncValue` in Riverpod for UI state management

**Error Types:**
- Throw on unexpected errors (network failures, API errors)
- Return null or special values for expected failures
- Log errors with `debugPrint` before rethrowing

**Example:**
```dart
try {
  return await _client.auth.signIn(email: email, password: password);
} catch (e) {
  debugPrint('AuthService: Sign in failed: $e');
  rethrow;
}
```

## Logging

**Framework:**
- `debugPrint` from Flutter foundation
- No structured logging library

**Patterns:**
- Log at service layer when errors occur
- Include context in log messages (e.g., `AuthService: Sign in failed`)
- No logging in production (debugPrint is stripped in release)

**When to Log:**
- External API errors
- Auth failures
- Purchase flow events (in RevenueCatService)

## Comments

**When to Comment:**
- Document public APIs with doc comments (`///`)
- Explain non-obvious business logic
- Document workarounds or temporary solutions

**Doc Comments:**
- Use `///` for documentation
- Include parameter descriptions for public methods
- Example:
```dart
/// Sign in with email and password.
/// Returns error message or null on success.
Future<String?> signIn(String email, String password) async {
```

**TODO Comments:**
- Format: `// TODO: description`
- Remove before release (see `lib/widgets/export_bottom_sheet.dart` for examples)

## Function Design

**Size:**
- Keep functions focused and under 50 lines when possible
- Extract helpers for complex logic
- Build methods in widgets can be longer but should be composed of smaller widgets

**Parameters:**
- Use named parameters for optional values
- Use positional parameters for required values
- Maximum 4-5 parameters, use data classes for more

**Return Values:**
- Explicit return types (enforced by lint rule)
- Use `Future<T>` for async functions
- Return `Result<T>` type for operations that can fail (see `lib/core/result.dart`)

## Widget Design

**Stateless vs Stateful:**
- Prefer `ConsumerWidget` (Riverpod) or `StatelessWidget`
- Use `ConsumerStatefulWidget` only when local mutable state needed
- Use `StatefulWidget` only when Riverpod not appropriate

**Constructor Parameters:**
- Use `required` for mandatory parameters
- Provide sensible defaults for optional parameters
- Use `super.key` for widget keys

**Build Method:**
- Keep build methods readable by extracting sub-widgets
- Use `const` constructors where possible

## Module Design

**Exports:**
- No barrel files (index.dart) except in `custom_code/`
- Import files directly by path

**State Management:**
- One provider per domain concern
- Providers should be in `lib/providers/`
- Services should be in `lib/services/`

## Code Generation

**When to Use:**
- Riverpod providers: Use `@riverpod` annotation with generator
- JSON serialization: Manual for core models (Project, Layer), can use `json_serializable` for others
- Immutable data: Manual `copyWith` for core models

**Build Runner:**
- Run: `flutter pub run build_runner build`
- Watch: `flutter pub run build_runner watch`
- Generated files: `*.g.dart`, `*.freezed.dart`

## Immutability

**Pattern:**
- All model classes are immutable (`@immutable` annotation)
- Use `final` for all fields
- Provide `copyWith` method for updates
- No mutable state in models

**Example:**
```dart
@immutable
class Project {
  const Project({...});
  
  final String id;
  final String name;
  // ...
  
  Project copyWith({...}) => Project(...);
}
```

---

*Convention analysis: 2026-02-04*
*Update when patterns change*
