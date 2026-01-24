# UAT Issues: Phase 8

**Tested:** 2026-01-25
**Source:** Phase 8 - Bug Fixes & Refinement
**Tester:** User via /gsd-verify-work

## Open Issues

### UAT-001: Sign Out doesn't clear project list

**Discovered:** 2026-01-25
**Phase/Plan:** 08
**Severity:** Major
**Feature:** Sign Out functionality
**Description:** Sign Out button works and account info disappears, but the project list still shows the previous user's projects.
**Expected:** Project list should be cleared on sign out (user data should not persist)
**Actual:** Projects remain visible after signing out
**Repro:**
1. Sign in and create/view projects
2. Go to Settings > Account > Sign Out
3. Observe project list still shows previous user's projects

## Resolved Issues

### UAT-001: Sign Out doesn't clear project list
**Resolved:** 2026-01-25 - Fixed in Phase 8
**Fix:** Added `clear()` method to ProjectListNotifier, called on sign out. Sets status to `loaded` with empty list to prevent loading spinner.

---

*Phase: 08-bug-fixes-refinement*
*Tested: 2026-01-25*
