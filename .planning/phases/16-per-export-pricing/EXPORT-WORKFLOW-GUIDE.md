# BuildShip Export Workflow Implementation Guide

**Purpose:** Documentation of the "Build Export" workflow in BuildShip.
**Reference:** Phase 9 SPEC.md (Workflow 3)
**Created:** 2026-01-26
**Updated:** 2026-01-27 (workflow complete, UAT passed)

---

## Status: PRODUCTION

The BuildShip export workflow is fully configured and tested.

**Full workflow JSON:** `BUILDSHIP-WORKFLOW-FINAL.json` (this directory)

---

## Workflow Architecture

```
Trigger (Supabase INSERT on exports)
    │
    ▼
Set Variable (supabase_url = https://dbluxquekhkihatcjplz.supabase.co)
    │
    ▼
Log Message (debug - logs the record)
    │
    ▼
Get Row (project_layers)
    │ - Table: project_layers
    │ - Filter: project_id=eq.{record.project_id}&visible=eq.true
    │ - API Key: supabase-key-layers (service role)
    │
    ▼
Switch (on record.type)
    │
    ├─── condition_1: type === "zip"
    │    │
    │    ▼
    │    Combine URLs to ZIP
    │    │ - URLs: layers[].png_url
    │    │ - Filename: {project_id}.zip
    │    │
    │    ▼
    │    Upload ZIP to Supabase Storage
    │    │ - Bucket: exports
    │    │ - Path: {project_id}/{export_id}.zip
    │    │
    │    ▼
    │    Update Row (exports)
    │      - status: "ready"
    │      - asset_url: filePath
    │
    ├─── condition_244204a8: type === "layersPack"
    │    │
    │    ▼
    │    (Same as ZIP branch)
    │
    ├─── condition_57b1f785: type === "pngs"
    │    │
    │    ▼
    │    Get PNG URL (Script)
    │    │ - Filters by options.layerIds if present
    │    │ - Returns first matching layer's png_url
    │    │
    │    ▼
    │    Update Row (exports)
    │      - status: "ready"
    │      - asset_url: pngUrl (direct public URL)
    │
    └─── condition_fallback: (no match)
         │
         ▼
         Update Row (exports)
           - status: "failed"
           - error_message: "Unknown export type: {type}"
```

---

## Key Node IDs

| Node | ID | Purpose |
|------|----|---------|
| Trigger | `706b38bb-5b6f-46d6-a2ca-59114ca80cc6` | Supabase INSERT on exports |
| Set Variable | `4543b35a-972f-43b4-b738-20f3088796c3` | Store supabase_url |
| Log Message | `a908e397-4312-41ef-a69b-27ec391682f0` | Debug logging |
| Get Row (layers) | `cc4709a5-6f4b-4714-b1a8-b446ffe6d3b7` | Fetch visible layers |
| Switch | `418779f3-0170-4949-a16d-0a97c9cdeec6` | Route by export type |
| Combine URLs (zip) | `8469133c-23f9-498a-97b1-d8c4f2f85c31` | Create ZIP file |
| Upload ZIP (zip) | `29766e7e-470d-430e-8d36-dd387242f147` | Upload to storage |
| Update Row (zip) | `3769742b-4d81-49ef-9b39-3cdc4f754d10` | Mark ready |
| Get PNG URL (pngs) | `e2ee4a2e-f69b-4b16-962b-57b088074604` | Extract PNG URL |
| Update Row (pngs) | `1b35a796-e528-468d-9a79-054bf5e2f6da` | Mark ready |
| Update Row (fallback) | `c6e7fcec-6d29-41e4-b9a7-ffec623a7991` | Mark failed |

---

## Environment Configuration

### Supabase Project
- **URL:** `https://dbluxquekhkihatcjplz.supabase.co`
- **Project Ref:** `dbluxquekhkihatcjplz`

### BuildShip Secrets
| Secret | Value |
|--------|-------|
| `supabase-key-layers` | Service role key (from Supabase Settings > API) |

### Storage Buckets
| Bucket | Purpose | Access |
|--------|---------|--------|
| `layers` | Layer PNGs from processing | Public read |
| `exports` | Export output files | Public read |

---

## Export Record Structure

The app creates export records with this structure:

```json
{
  "id": "uuid",
  "project_id": "uuid",
  "type": "pngs" | "zip" | "layersPack",
  "status": "queued",
  "options": { "layerIds": ["uuid", ...] },
  "asset_url": null,
  "error_message": null,
  "created_at": "timestamp"
}
```

**Status Flow:** `queued` → `ready` (or `failed`)

Note: The workflow does not set `processing` status - it goes directly to `ready` or `failed`.

---

## Get PNG URL Script

```javascript
export default function getPngUrl({ layers, options }: NodeInputs) {
  if (!layers || layers.length === 0) {
    throw new Error("No layers found");
  }
  
  let targetLayers = layers;
  
  // Filter by layerIds if specified
  if (options?.layerIds && Array.isArray(options.layerIds) && options.layerIds.length > 0) {
    targetLayers = layers.filter(l => options.layerIds.includes(l.id));
  }
  
  if (targetLayers.length === 0) {
    throw new Error("No matching layers found");
  }
  
  // Return first layer's PNG URL (already a public URL)
  return {
    pngUrl: targetLayers[0].png_url,
    layerCount: targetLayers.length
  };
}
```

**Inputs:**
- `layers`: `ctx?.["nodes"]?.["cc4709a5-6f4b-4714-b1a8-b446ffe6d3b7"]`
- `options`: `ctx?.["root"]?.["inputs"]?.["record"].options`

---

## Testing Checklist

### Test ZIP Export
- [ ] Create project with 2+ layers
- [ ] Tap Export > All Layers (ZIP)
- [ ] Verify export status → `ready`
- [ ] Verify `asset_url` points to `.zip` file
- [ ] Download works

### Test layersPack Export
- [ ] Tap Export > Project Pack (.layers)
- [ ] Verify export status → `ready`
- [ ] Verify ZIP file created

### Test pngs Export
- [ ] Select a single layer
- [ ] Tap Export > Single Layer (PNG)
- [ ] Verify export status → `ready`
- [ ] Verify `asset_url` is direct PNG URL
- [ ] Download works

### Test Fallback
- [ ] Manually insert export with `type: "invalid"`
- [ ] Verify export status → `failed`
- [ ] Verify `error_message` set

---

## Troubleshooting

### Export stays in "queued"
- Check BuildShip workflow is deployed
- Check Supabase webhook is configured
- Check BuildShip logs for errors

### "Invalid Compact JWS" error
- Using anon key instead of service role key
- Update to use `supabase-key-layers` secret

### No layers found
- Project has no visible layers
- Check `project_layers` table

### Upload fails
- Storage bucket doesn't exist
- RLS policies blocking (use service role key)

---

## App-Side Notes

### Debug Flag
The app has a debug flag that can force the purchase sheet:
```dart
// lib/widgets/export_bottom_sheet.dart
static const _debugForcePurchaseSheet = false;  // Set to true for testing
```

### Export Subscription
The app subscribes to export updates via Supabase Realtime:
```dart
exportService.subscribeToExport(exportId).listen((export) {
  if (export.isComplete && export.assetUrl != null) {
    // Show download button
  }
});
```

---

*Phase 16 - Export Workflow Guide*
*Status: Complete*
*Updated: 2026-01-27*
