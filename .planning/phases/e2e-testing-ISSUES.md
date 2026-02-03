# UAT Issues: End-to-End Testing

**Tested:** 2026-02-03
**Scope:** Full project flow — create project → BuildShip processing → view layers → export
**Tester:** User via manual testing

## Open Issues

[None - all issues resolved in UAT-FIX-20260203]

## Resolved Issues

### UAT-001: Layer visibility/order incorrect in list panel ✓ FIXED

**Discovered:** 2026-02-03
**Resolved:** 2026-02-03 (corrected 2026-02-03)
**Severity:** Major
**Feature:** Layer List Panel (right sidebar)
**Fix Commit:** 85b5fc3

**Problem:** The layer list panel showed layers in wrong order — Layer 1 (z:0, background) appeared at the TOP of the list, while Layer 4 (z:3, front-most) appeared at the BOTTOM. This is inverted compared to standard design tools (Photoshop, Figma) where the front-most layer appears at the top of the list.

**Root Cause:** The `LayerListPanel` displayed layers in their raw state order without sorting by zIndex. In design tools, the layer at the TOP of the list should be the FRONT-MOST layer (highest z-index).

**Solution:** 
- Modified `layer_list_panel.dart` to sort layers by zIndex DESCENDING before displaying
- Highest zIndex (front-most) now appears at the TOP of the list
- Fixed reorder logic to correctly map visual list indices to actual layer indices
- 3D viewer rendering reverted to original ascending sort (back-to-front for Stack painting)

**Files Modified:**
- `lib/widgets/layer_list_panel.dart` — sorts by zIndex descending, fixed reorder mapping
- `lib/widgets/layer_space_view.dart` — reverted to ascending sort (correct for 3D rendering)

### UAT-002: Download link fails on Android ✓ FIXED

**Discovered:** 2026-02-03
**Resolved:** 2026-02-03
**Severity:** Major
**Feature:** Export/Download functionality
**Platform:** Android only
**Fix Commit:** [pending]

**Problem:** When tapping the "Download" link, a snackbar appeared with "Could not open download link" error. `canLaunchUrl()` was returning false on Android, preventing downloads.

**Solution:**
- Removed reliance on `canLaunchUrl()` check which was unreliable on Android
- Added try-catch error handling for better debugging
- Implemented fallback to `LaunchMode.platformDefault` if external application mode fails
- Added more descriptive error messages

**Files Modified:**
- `lib/widgets/export_bottom_sheet.dart`

### UAT-003: Manage button doesn't work on Android ✓ FIXED

**Discovered:** 2026-02-03
**Resolved:** 2026-02-03
**Severity:** Major
**Feature:** Subscription Management
**Platform:** Android only
**Fix Commit:** [pending]

**Problem:** The "Manage" button in Settings for Pro subscribers was hardcoded to iOS App Store URL (`https://apps.apple.com/account/subscriptions`), so it did nothing on Android devices.

**Solution:**
- Added platform detection using `defaultTargetPlatform`
- iOS/macOS: Opens Apple App Store subscription management
- Android: Opens Google Play Store subscription management
- Added error handling with fallback snackbar if launch fails

**Files Modified:**
- `lib/screens/settings_screen.dart`

## Passed Tests

- Project creation (anonymous): PASS
- BuildShip processing: PASS

---

*Tested: 2026-02-03*
*Fixed: 2026-02-03*
*All UAT issues resolved - ready for re-testing*
