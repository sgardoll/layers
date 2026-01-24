# UAT Issues: Phase 4 Plan 02

**Tested:** 2026-01-24
**Source:** .planning/phases/04-export-persistence/04-02-SUMMARY.md
**Tester:** User via /gsd-verify-work

## Open Issues

[All resolved]

## Resolved Issues

### UAT-001: Delete project doesn't remove storage file
**Resolved:** 2026-01-24 - Fixed in commit 0e63a90
**Description:** When deleting a project, the database row is removed but the uploaded image file remains in the `source-images` storage bucket.
**Fix:** Added deleteStorageFile method to SupabaseProjectService. deleteProject now cleans up source-images bucket.

### UAT-002: Export screen not accessible
**Resolved:** 2026-01-24 - Fixed in commit 0e63a90
**Description:** ExportScreen was built but there's no navigation route to access it from the app.
**Fix:** Added Exports tab to bottom navigation bar, added /exports route to app router, modified ExportScreen to show all exports when no projectId.

---

*Phase: 04-export-persistence*
*Tested: 2026-01-24*
