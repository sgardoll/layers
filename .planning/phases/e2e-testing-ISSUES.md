# UAT Issues: End-to-End Testing

**Tested:** 2026-02-03
**Scope:** Full project flow — create project → BuildShip processing → view layers → export
**Tester:** User via manual testing

## Open Issues

### UAT-001: Layer visibility/order incorrect in 3D viewer

**Discovered:** 2026-02-03
**Severity:** Major
**Feature:** 3D Layer Viewer
**Description:** The schematic outline of layers shows correct z-order (Layer 1 in front of Layer 3), but the actual image rendering shows Layer 1 BEHIND Layer 3. Additionally, hidden layers display a black semi-transparent haze that complicates the visual presentation.

**Expected:** 
- Layer 1 image should render in front of Layer 3 image (matching the schematic outline)
- Hidden layers should have clear visual indication without confusing haze effects

**Actual:**
- Schematic outline: Layer 1 in front ✓
- Image rendering: Layer 1 behind Layer 3 ✗
- Black semi-transparent overlay on hidden layers creates visual confusion

**Repro:**
1. Create project with multiple layers
2. Open 3D layer viewer
3. Observe schematic cards vs actual image positions
4. Hide some layers and observe the haze effect

### UAT-002: Download link fails on Android

**Discovered:** 2026-02-03
**Severity:** Major
**Feature:** Export/Download functionality
**Platform:** Android only
**Description:** When tapping the "Download" link in either the Projects bottom sheet or the Exports screen, a snackbar appears with "Could not open download link" error. This prevents users from downloading their exported files on Android.

**Expected:** Download link opens browser or download manager to retrieve the exported file

**Actual:** Snackbar shows "Could not open download link" — download fails

**Repro:**
1. On Android device, create and process a project
2. Go to Projects tab, tap project, tap "Download" in bottom sheet — OR —
3. Go to Exports tab, tap "Download" on an export
4. Observe error snackbar

## Passed Tests

- Project creation (anonymous): PASS
- BuildShip processing: PASS

## Notes

- Layer ordering bug suggests z-index or transform rendering issue in 3D viewer
- Android download issue may be related to URL handling, permissions, or intent resolution
- Both issues are functional blockers for their respective features

---

*Tested: 2026-02-03*
*Next: Plan fixes for UAT-001 and UAT-002*
