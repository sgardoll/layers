---
phase: 16-per-export-pricing
plan: 16-FIX
subsystem: infra
tags: [buildship, workflow, exports, supabase-webhook]

requires:
  - phase: 09-buildship-workflow-spec
    provides: Workflow 3 (Build Export) specification

provides:
  - Export workflow implementation guide
  - Fully configured BuildShip workflow with all export types
  - Resolution of UAT-002

affects: [exports, buildship]

tech-stack:
  added: []
  patterns: [buildship-webhook-workflow, switch-branch-routing]

key-files:
  created:
    - .planning/phases/16-per-export-pricing/EXPORT-WORKFLOW-GUIDE.md
  modified:
    - .planning/phases/16-per-export-pricing/16-ISSUES.md
    - lib/widgets/export_bottom_sheet.dart (debug flag disabled)

key-decisions:
  - "Created implementation guide for BuildShip workflow"
  - "Used Switch node for export type routing (zip, layersPack, pngs, fallback)"
  - "PNG URLs are already public - no signed URLs needed"
  - "ZIP files stored in exports bucket with path {project_id}/{export_id}.zip"

issues-created: []

duration: ~2 hours (across multiple sessions)
completed: 2026-01-27
---

# Phase 16 Fix: Export Workflow Complete

**BuildShip export workflow fully configured and ready for testing**

## Performance

- **Duration:** ~2 hours (iterative debugging with user)
- **Started:** 2026-01-26
- **Completed:** 2026-01-27
- **Tasks:** 3/3 Complete
- **Files created:** 1
- **Files modified:** 2

## Accomplishments

1. Created comprehensive `EXPORT-WORKFLOW-GUIDE.md` with step-by-step BuildShip setup
2. Configured complete BuildShip workflow with all 4 branches:
   - **ZIP branch:** Combine layer URLs → Upload ZIP → Update export status
   - **layersPack branch:** Same as ZIP (creates .zip file)
   - **pngs branch:** Get single PNG URL → Update export with direct URL
   - **fallback branch:** Mark export as failed with error message
3. Fixed app-side debug flag blocking exports
4. Resolved all debugging issues (API key, filter syntax, path references)

## BuildShip Workflow Architecture

```
Trigger (Supabase INSERT on exports)
    ↓
Set Variable (supabase_url)
    ↓
Log Message (debug)
    ↓
Get Row (project_layers, filtered by project_id & visible=true)
    ↓
Switch (on record.type)
    ├── condition_1 (zip)
    │   └── Combine URLs → Upload ZIP → Update Row (ready)
    ├── condition_244204a8 (layersPack)
    │   └── Combine URLs → Upload ZIP → Update Row (ready)
    ├── condition_57b1f785 (pngs)
    │   └── Get PNG URL Script → Update Row (ready)
    └── condition_fallback
        └── Update Row (failed, error_message)
```

## Key Node IDs (for reference)

| Node | ID |
|------|-----|
| Trigger | `706b38bb-5b6f-46d6-a2ca-59114ca80cc6` |
| Get Row (layers) | `cc4709a5-6f4b-4714-b1a8-b446ffe6d3b7` |
| Switch | `418779f3-0170-4949-a16d-0a97c9cdeec6` |
| ZIP node | `8469133c-23f9-498a-97b1-d8c4f2f85c31` |
| Upload node | `29766e7e-470d-430e-8d36-dd387242f147` |
| Get PNG URL script | `e2ee4a2e-f69b-4b16-962b-57b088074604` |

## Task Status

| Task | Status | Notes |
|------|--------|-------|
| 1. Create Export Workflow Guide | ✅ Complete | EXPORT-WORKFLOW-GUIDE.md |
| 2. Update 16-ISSUES.md | ✅ Complete | UAT-002 resolved |
| 3. Configure BuildShip workflow | ✅ Complete | All branches implemented |

## Files Created

- `.planning/phases/16-per-export-pricing/EXPORT-WORKFLOW-GUIDE.md` — Step-by-step BuildShip configuration guide

## Files Modified

- `.planning/phases/16-per-export-pricing/16-ISSUES.md` — UAT-002 marked resolved
- `lib/widgets/export_bottom_sheet.dart` — Disabled debug flag (`_debugForcePurchaseSheet = false`)

## Debugging Issues Resolved

| Issue | Cause | Fix |
|-------|-------|-----|
| `Invalid Compact JWS` | Using anon key instead of service role | Use `supabase-key-layers` (service role key) |
| Filter not working | Used `,` separator | Use `&` for multiple filters |
| Options as string | Template literal wrapper | Direct expression without backticks |
| ZIP upload path | Hardcoded path | Dynamic `{project_id}/{export_id}.zip` |

## Technical Details

### Supabase Configuration
- **Project URL:** `https://dbluxquekhkihatcjplz.supabase.co`
- **Project Ref:** `dbluxquekhkihatcjplz`
- **API Key:** `supabase-key-layers` (service role)

### Storage Buckets
- `layers` — Layer PNGs (public read)
- `exports` — Export files (public read)

### Export Status Flow
```
queued → processing → ready (or failed)
```

## Next Steps

1. **Test all export types:**
   - Create export with `type: zip` → verify ZIP download
   - Create export with `type: layersPack` → verify ZIP download
   - Create export with `type: pngs` (with selected layer) → verify PNG URL
   - Create export with invalid type → verify `failed` status

2. **End-to-end verification:**
   - App shows "Processing..." during workflow execution
   - App shows "Ready to download!" when `status='ready'`
   - Download button opens `asset_url`

3. **Phase 16 completion:**
   - After successful testing, Phase 16 can be marked complete
   - RevenueCat product configuration is optional for MVP (debug flag bypasses)

---
*Phase: 16-per-export-pricing*
*Plan: 16-FIX*
*Completed: 2026-01-27*
