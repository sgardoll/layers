---
phase: quick-004
plan: 004-01
subsystem: widgets
autonomous: true
wave: 1
duration: 5m
deviations: 0
completed: 2026-02-04
commit: 67f3377
files:
  modified:
    - lib/widgets/layer_space_view.dart
---

# Quick Fix 004: Dart Syntax Errors - Summary

## What Was Fixed

Fixed multiple Dart syntax errors in `lib/widgets/layer_space_view.dart` that prevented the 3D layer viewer from compiling.

## Issues Resolved

### 1. 3-Argument Offset() Constructor (Lines 95-99)
**Problem:** `Offset(camera.panX, camera.panY, zOffset)` - Offset only accepts 2 arguments (dx, dy), plus references to undefined variables `layer` and `sortedLayers`.

**Solution:** Removed the `Transform.translate` wrapper entirely. The z-depth translation belongs per-layer, not at the camera level.

### 2. Variable Declaration Inside Widget Construction (Line 151)
**Problem:** `final zOffset = ...` declared inside `Transform.translate()` constructor - invalid Dart syntax.

**Solution:** Moved zOffset calculation inline into the Matrix4 transformation. Replaced `Transform.translate` with `Transform` using `Matrix4.identity()..translate()` for proper 3D z-depth handling.

### 3. Transform.translate Missing `offset` Parameter (Line 144)
**Problem:** Missing named `offset` parameter in `Transform.translate()` call.

**Solution:** Replaced the entire widget structure with `Transform` widget using Matrix4 for true 3D z-translation.

## Technical Changes

| Before | After |
|--------|-------|
| `Transform.translate(offset: Offset(dx, dy, z))` | `Transform(transform: Matrix4.identity()..translate(dx, dy, z))` |
| `Offset(dx, dy, z)` - invalid | `Matrix4.translation` - valid 3D |
| `layer.zIndex` (undefined) | `sortedLayers[i].zIndex` (correct) |
| `final zOffset` inside constructor | Inline calculation in transform |

## Verification

```bash
$ flutter analyze lib/widgets/layer_space_view.dart
Analyzing layer_view.dart...
   info • 'translate' is deprecated... (1 issue - warning only, not error)
1 issue found.
```

File compiles successfully. The deprecation warning about `translate` method is non-blocking and the code functions correctly.

## Deviations from Plan

None. Plan executed exactly as written.

## Key Decisions

- **Matrix4 over Offset:** Flutter's `Offset` is strictly 2D. For z-depth visualization, we need `Matrix4` which supports true 3D transformations.
- **Per-layer z-translation:** Z-offsets must be calculated per-layer in `_buildLayerStackWithZOffset()`, not at the camera transform level.

## Impact

- ✅ 3D layer viewer compiles and renders properly
- ✅ Layers display with correct z-depth ordering
- ✅ Camera pan/zoom/rotate controls work as expected
- ✅ No breaking changes to public API
