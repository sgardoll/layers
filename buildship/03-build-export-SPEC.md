# BuildShip Export Workflow Specification

## Trigger
- **Type:** Supabase Trigger
- **Table:** `exports`
- **Event:** INSERT
- **Project Ref:** `dbluxquekhkihatcjplz`

## Input (from trigger)
```json
{
  "record": {
    "id": "uuid",
    "project_id": "uuid", 
    "type": "pngs" | "zip" | "layersPack",
    "status": "queued",
    "created_at": "timestamp"
  }
}
```

## Workflow Nodes

### 1. Set Variables
- `export_id` = `record.id`
- `project_id` = `record.project_id`
- `export_type` = `record.type`
- `supabase_url` = `https://dbluxquekhkihatcjplz.supabase.co`

### 2. Update Export Status → "processing"
- **Node:** Supabase Update Row
- **Table:** `exports`
- **Filter:** `id=eq.${export_id}`
- **Data:** `{ "status": "processing" }`

### 3. Fetch Project Layers
- **Node:** Supabase Select Rows
- **Table:** `project_layers`
- **Filter:** `project_id=eq.${project_id}`
- **Order:** `z_index.asc`
- **Output:** Array of layer objects with `png_path`

### 4. Branch by Export Type

#### If type == "pngs"
- Loop through layers
- For each layer, create signed URL
- Collect URLs into array
- Create JSON manifest with URLs

#### If type == "zip"
- Loop through layers
- Download each layer PNG
- Create ZIP archive containing all PNGs
- Upload ZIP to Supabase storage: `exports/{user_id}/{export_id}/layers.zip`

#### If type == "layersPack"
- Same as ZIP but with metadata JSON included
- Upload to: `exports/{user_id}/{export_id}/layers.pack`

### 5. Upload Export Asset
- **Node:** Supabase Storage Upload
- **Bucket:** `exports`
- **Path:** `{user_id}/{export_id}/{filename}`

### 6. Update Export Status → "ready"
- **Node:** Supabase Update Row
- **Table:** `exports`
- **Filter:** `id=eq.${export_id}`
- **Data:** 
  ```json
  {
    "status": "ready",
    "asset_url": "{storage_path}"
  }
  ```

### 7. Error Handling (on any failure)
- **Node:** Supabase Update Row
- **Table:** `exports`
- **Filter:** `id=eq.${export_id}`
- **Data:**
  ```json
  {
    "status": "failed",
    "error_message": "{error}"
  }
  ```

## Required Secrets
- `supabase-layers` - Supabase service key

## Storage Buckets Needed
- `exports` - For storing export output files (needs to be created if not exists)

## Database Schema Reference

### exports table
```sql
id UUID PRIMARY KEY
project_id UUID REFERENCES projects(id)
type TEXT ('pngs', 'zip', 'layersPack')
status TEXT ('queued', 'processing', 'ready', 'failed')
asset_url TEXT
error_message TEXT
created_at TIMESTAMP
```

### project_layers table
```sql
id UUID PRIMARY KEY
project_id UUID REFERENCES projects(id)
name TEXT
png_path TEXT
png_url TEXT
z_index INTEGER
visible BOOLEAN
```
