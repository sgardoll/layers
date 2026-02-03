# UAT Issues: End-to-End Testing

**Tested:** 2026-02-03
**Scope:** Full project flow — create project → BuildShip processing → view layers → export
**Tester:** User via manual testing

## Open Issues

[None - all issues resolved in UAT-FIX-20260203]

## Resolved Issues

### UAT-001: Layer visibility/order incorrect in 3D viewer ✓ FIXED

**Discovered:** 2026-02-03
**Resolved:** 2026-02-03
**Severity:** Major
**Feature:** 3D Layer Viewer
**Fix Commit:** [pending]

**Problem:** The schematic outline of layers showed correct z-order (Layer 1 in front of Layer 3), but the actual image rendering showed Layer 1 BEHIND Layer 3. Additionally, hidden layers displayed a dark semi-transparent haze.

**Solution:** 
- Fixed layer sorting in `layer_space_view.dart` to use descending zIndex order
- Reversed the iteration order so front layers (higher zIndex) are painted last in the Stack
- Reduced hidden layer overlay opacity from 0.7 to 0.4 for clearer visual indication
- Changed icon color from `Colors.white54` to `Colors.white70` for better visibility

**Files Modified:**
- `lib/widgets/layer_space_view.dart`
- `lib/widgets/layer_card_3d.dart`

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
