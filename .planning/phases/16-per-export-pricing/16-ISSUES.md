# UAT Issues: Phase 16 - Per-Export Pricing

**Tested:** 2026-01-26, 2026-01-27
**Source:** Phase 16 implementation + 16-FIX-SUMMARY.md
**Tester:** User via manual UAT

## Open Issues

### UAT-003: RevenueCat consumable pricing incorrect

**Discovered:** 2026-01-27
**Phase/Plan:** 16
**Severity:** Minor (configuration, not code)
**Feature:** Export purchase paywall
**Description:** One-time purchase shows $0.49 instead of $0.99
**Expected:** Price should be $0.99
**Actual:** Price shows $0.49
**Action:** Update price in RevenueCat dashboard / App Store Connect

### UAT-004: iOS sandbox purchase flow fails

**Discovered:** 2026-01-27
**Phase/Plan:** 16
**Severity:** Major (blocks purchase testing)
**Feature:** Export purchase flow
**Description:** After entering Apple ID credentials, purchase flow returns to bottom sheet without completing
**Expected:** Purchase should complete or show error
**Actual:** Silent failure - returns to export options
**Possible Causes:** 
- Non-sandbox Apple ID on dev build
- Consumable product not fully configured in App Store Connect
**Workaround:** Debug flag `_debugSkipPaymentGate = true` bypasses payment for testing

## Blocked Issues (Infrastructure)

(None)

## Resolved Issues

### UAT-005: Layer number display off-by-one in export sheet

**Discovered:** 2026-01-27
**Resolved:** 2026-01-27
**Phase/Plan:** 16
**Severity:** Minor
**Feature:** Export bottom sheet
**Description:** Selecting "Layer 3" showed "Layer 2" in export sheet
**Expected:** Layer numbers should match between list and export sheet
**Actual:** Export sheet showed `zIndex` (0-indexed) while list shows `zIndex + 1`
**Fix:** Changed export sheet to use `zIndex + 1` to match layer list display

### UAT-001: Export button was not wired up

**Discovered:** 2026-01-26
**Resolved:** 2026-01-26
**Phase/Plan:** 16
**Severity:** Blocker
**Feature:** Export button in layers screen
**Description:** Tapping export FAB did nothing
**Expected:** Export bottom sheet should appear
**Actual:** Empty callback
**Fix:** Added ExportBottomSheet.show() call

### UAT-006: BuildShip filePath expression type wrong

**Discovered:** 2026-01-27
**Resolved:** 2026-01-27
**Phase/Plan:** 16
**Severity:** Blocker
**Feature:** ZIP export upload
**Description:** Upload failed with "Invalid key" error containing literal `${uuid}` in path
**Expected:** Path should be evaluated to actual UUID values
**Actual:** Template literal `${}` not evaluated - expression type was "text" instead of "javascript"
**Fix:** Changed File Path expression type from "text" to "javascript" in BuildShip Upload nodes

### UAT-007: BuildShip storing filePath instead of downloadUrl

**Discovered:** 2026-01-27
**Resolved:** 2026-01-27
**Phase/Plan:** 16
**Severity:** Blocker
**Feature:** Export download
**Description:** Download button showed "Could not open download link"
**Expected:** asset_url should be full public URL
**Actual:** asset_url contained relative path (e.g., "uuid/uuid.zip") instead of full URL
**Fix:** Changed BuildShip Update Row nodes to use `downloadUrl` instead of `filePath`

### UAT-002: Export processing workflow not configured

**Discovered:** 2026-01-26
**Resolved:** 2026-01-27
**Phase/Plan:** 16
**Severity:** Blocker (infrastructure dependency)
**Feature:** Export processing
**Description:** BuildShip workflow for processing exports is not set up
**Expected:** After payment gate passes, export should be processed by BuildShip
**Actual:** Export record created in Supabase but never processed

**Resolution:**
BuildShip workflow fully configured with all export types:

| Branch | Condition | Flow | Status |
|--------|-----------|------|--------|
| **zip** | `type === "zip"` | Combine URLs → Upload ZIP → Update export (`ready`) | ✅ |
| **layersPack** | `type === "layersPack"` | Combine URLs → Upload ZIP → Update export (`ready`) | ✅ |
| **pngs** | `type === "pngs"` | Get PNG URL (with layerIds filter) → Update export (`ready`) | ✅ |
| **fallback** | (no match) | Update export (`failed`, error message) | ✅ |

**Key Node IDs:**
- Trigger: `706b38bb-5b6f-46d6-a2ca-59114ca80cc6`
- Get Row (layers): `cc4709a5-6f4b-4714-b1a8-b446ffe6d3b7`
- Switch: `418779f3-0170-4949-a16d-0a97c9cdeec6`

**Technical Details:**
- Uses `supabase-key-layers` (service role key) for all Supabase operations
- Layers are fetched with `visible=eq.true` filter
- PNG URLs are already public (no signed URLs needed)
- ZIP files uploaded to `exports` bucket with path `{project_id}/{export_id}.zip`

### UAT-001: Export button was not wired up
**Resolved:** 2026-01-26 - Fixed inline during testing
**Fix:** Added ExportBottomSheet.show() to layers_screen.dart

---

*Phase: 16-per-export-pricing*
*Tested: 2026-01-26*
