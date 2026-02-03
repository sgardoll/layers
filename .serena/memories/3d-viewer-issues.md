## 3D Viewer Issues Discovered During UAT

### Issue 1: Layer Ordering (UAT-001 - ORIGINAL)
**Status:** Partially fixed
**Issue:** Schematic outline shows correct z-order but actual image rendering shows Layer 1 BEHIND Layer 3

### Issue 2: Schematic Labels (NEW - UAT-002)
**Status:** New bug introduced
**Severity:** Major
**Issue:** Schematic labels are now reversed. Layer 4 is labeled as "Layer 1", Layer 3 as "Layer 2", etc.
**Expected:** Schematics should show labels matching the actual layer order (Layer 1 in front)
**Actual:** Labels are reversed/inverted

### Issue 3: Hidden Layer Haze (UAT-003)
**Status:** Still present
**Issue:** Black semi-transparent overlay on hidden layers creates visual confusion

**Tested:** 2026-02-03
**Platform:** macOS/iOS
