# UAT Issues: Phase 13 Plan 1

**Tested:** 2026-01-25
**Source:** Phase 13 - App Flow Verification (LayersScreen auto-fetch)
**Tester:** User via /gsd-verify-work

## Open Issues

### UAT-001: Layer images fail to load - invalid URL stored in database

**Discovered:** 2026-01-25
**Phase/Plan:** 13-01
**Severity:** Blocker
**Feature:** Layers display in 3D viewer
**Description:** Layer images don't appear in the layers screen. NetworkImage throws "No host specified in URI" error.
**Expected:** Full Supabase Storage public URL stored in `png_url` column, e.g., `https://xxx.supabase.co/storage/v1/object/public/layers/user_id/project_id/layer_0.png`
**Actual:** Only relative path stored: `layers/2e86958c-46b3-4fbd-81cb-892320a65cff/3496466e-a922-44c4-a09a-09cf7a1dc1e0/layer_0.png`
**Repro:**
1. Create a new project
2. Upload an image
3. Wait for BuildShip workflow to complete (status becomes `ready`)
4. Tap the project to open LayersScreen
5. Observe: layer cards appear but images show broken/empty

**Root Cause:** BuildShip workflow's "Create Row" node stores the storage path from upload result instead of constructing the full public URL.

**Fix Required:** In BuildShip workflow, after uploading to storage, construct the full public URL:
```
https://{SUPABASE_PROJECT_ID}.supabase.co/storage/v1/object/public/{bucket}/{path}
```

## Resolved Issues

[None yet]

---

*Phase: 13-app-flow-ready-to-layers*
*Plan: 01*
*Tested: 2026-01-25*
