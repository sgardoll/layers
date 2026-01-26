---
phase: 14-remove-layers-from-app-bar
plan: 01
status: complete
---

## Summary

Removed "Layers" tab from bottom navigation bar, reducing from 4 tabs to 3 (Projects, Exports, Settings).

## Accomplishments

1. **Removed Layers NavigationDestination** from `app_shell.dart` - navigation bar now shows 3 tabs
2. **Removed /layers branch** from `app_router.dart` - Layers is no longer a top-level tab
3. **Verified navigation flow** - LayersScreen still accessible via `MaterialPageRoute` from ProjectScreen (no changes needed)

## Key Decisions

- LayersScreen remains accessible via direct navigation from ProjectScreen after creating a project
- Removed unused `layers_screen.dart` import from router since it's no longer used there

## Files Modified

- `lib/widgets/app_shell.dart` - Removed Layers NavigationDestination
- `lib/router/app_router.dart` - Removed /layers branch, removed unused import

## Commits

- `1267c8e`: feat(14-01): remove Layers tab from navigation

## Verification

- [x] flutter analyze passes with no errors
- [x] App builds successfully
- [x] Bottom nav shows 3 tabs only (Projects, Exports, Settings)
- [x] Layers functionality still accessible via project flow (MaterialPageRoute)
