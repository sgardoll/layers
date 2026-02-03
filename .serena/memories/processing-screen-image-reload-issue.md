# Processing Screen Causes Full UI Reload

## Problem
When a new project is added and reaches the "Processing" screen, the entire UI reloads. This forces all project images to re-download, causing:
- Noticeable lag/flickering
- Images showing as blank (previously loaded images disappear)
- Poor UX during the already-long processing wait

## Affected Areas
- Project creation flow
- Projects list screen
- Image loading/caching

## Possible Solutions
1. **Prevent full UI reload** - Use Riverpod's select() or similar to only update the new project state
2. **Better image caching** - Ensure CachedNetworkImage is properly configured
3. **Optimistic UI updates** - Show placeholder immediately, update in background
4. **State management fix** - Check if project provider is unnecessarily invalidating all projects

## Related Files
- lib/screens/project_screen.dart (likely)
- lib/widgets/processing_indicator.dart
- lib/providers/project_provider.dart

## Priority
Medium-High — affects every user during project creation, which is core functionality
