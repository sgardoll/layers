# UAT Issues: Phase 4 Plan 02

**Tested:** 2026-01-24
**Source:** .planning/phases/04-export-persistence/04-02-SUMMARY.md
**Tester:** User via /gsd-verify-work

## Open Issues

### UAT-001: Delete project doesn't remove storage file

**Discovered:** 2026-01-24
**Phase/Plan:** 04-02
**Severity:** Minor
**Feature:** Delete project
**Description:** When deleting a project, the database row is removed but the uploaded image file remains in the `source-images` storage bucket.
**Expected:** Both database entry AND storage file should be deleted
**Actual:** Only database entry deleted, storage file orphaned
**Repro:**
1. Create a project (upload image)
2. Delete the project via 3-dot menu
3. Check Supabase storage - file still exists

### UAT-002: Export screen not accessible

**Discovered:** 2026-01-24
**Phase/Plan:** 04-01
**Severity:** Minor
**Feature:** Export history screen
**Description:** ExportScreen was built but there's no navigation route to access it from the app.
**Expected:** Export screen accessible from bottom nav or project menu
**Actual:** No way to navigate to export screen
**Repro:** Look for Export option in navigation - doesn't exist

## Resolved Issues

[None yet]

---

*Phase: 04-export-persistence*
*Tested: 2026-01-24*
