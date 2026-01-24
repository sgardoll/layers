# BuildShip Workflow Specification

**Phase 9**: Full specification for the 3 BuildShip workflows
**Purpose**: Guide manual creation of workflows in BuildShip dashboard

## Overview

Layers uses 3 BuildShip workflows triggered by Supabase webhooks:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| 1. Run Layering Job | `projects` INSERT | Process uploaded image into transparent layers using AI |
| 2. Cleanup Project | `project_layers` DELETE | Remove orphaned layer files from storage |
| 3. Build Export | `exports` INSERT | Composite layers into final export image |

---

## Database Schema Reference

### `projects` table
```sql
id              UUID PRIMARY KEY
user_id         UUID REFERENCES auth.users(id)
source_image_path TEXT    -- e.g., "user_id/project_id/source.jpg"
params          JSONB     -- processing parameters
status          TEXT      -- 'queued' | 'processing' | 'completed' | 'failed'
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

### `project_layers` table
```sql
id              UUID PRIMARY KEY
project_id      UUID REFERENCES projects(id)
name            TEXT      -- layer name from AI
png_url         TEXT      -- storage path to layer PNG
width           INT
height          INT
z_index         INT       -- layer order (0 = bottom)
visible         BOOLEAN
bbox            JSONB     -- {x, y, width, height} bounding box
transform       JSONB     -- {x, y, scale, rotation, opacity}
created_at      TIMESTAMP
```

### `exports` table
```sql
id              UUID PRIMARY KEY
project_id      UUID REFERENCES projects(id)
format          TEXT      -- 'png' | 'jpg' | 'psd'
status          TEXT      -- 'queued' | 'processing' | 'completed' | 'failed'
output_url      TEXT      -- storage path to final export
created_at      TIMESTAMP
```

### Storage Buckets
- `source-images`: Original uploaded images (`{user_id}/{project_id}/source.{ext}`)
- `layers`: Processed layer PNGs (`{user_id}/{project_id}/layers/{layer_id}.png`)
- `exports`: Final export files (`{user_id}/{project_id}/exports/{export_id}.{ext}`)

---

## Workflow 1: Run Layering Job

### Trigger
- **Type**: Supabase Webhook
- **Table**: `projects`
- **Event**: INSERT
- **Schema**: public

### Input (from webhook payload)
```json
{
  "type": "INSERT",
  "table": "projects",
  "record": {
    "id": "uuid",
    "user_id": "uuid",
    "source_image_path": "user_id/project_id/source.jpg",
    "params": {},
    "status": "queued"
  }
}
```

### Node Flow

```
[Supabase Trigger] 
    → [Update Project Status to 'processing']
    → [Get Signed URL for Source Image]
    → [Call AI Layer Extraction API]
    → [For Each Layer: Upload PNG to Storage]
    → [For Each Layer: Insert into project_layers]
    → [Update Project Status to 'completed']
    → [Error Handler: Update Status to 'failed']
```

### Node Specifications

#### Node 1: Update Project Status (processing)
- **Type**: Supabase Update Row
- **Table**: `projects`
- **Filter**: `id = record.id`
- **Update**: `{ "status": "processing", "updated_at": "NOW()" }`

#### Node 2: Get Signed URL
- **Type**: Supabase Storage - Create Signed URL
- **Bucket**: `source-images`
- **Path**: `record.source_image_path`
- **Expires**: 3600 seconds
- **Output**: `signedUrl`

#### Node 3: Call AI Layer Extraction
- **Type**: HTTP Request (or fal.ai node if available)
- **Method**: POST
- **URL**: `https://fal.run/fal-ai/birefnet` (or similar segmentation model)
- **Headers**: 
  ```json
  {
    "Authorization": "Key ${secrets.FAL_API_KEY}",
    "Content-Type": "application/json"
  }
  ```
- **Body**:
  ```json
  {
    "image_url": "${signedUrl}",
    "model_type": "General Use (Light)",
    "operating_resolution": "1024x1024",
    "output_format": "png"
  }
  ```
- **Output**: Array of layer objects with URLs

#### Node 4: Loop - Process Each Layer
- **Type**: Loop/Iterator
- **Input**: AI response layers array
- **For Each**: Execute nodes 5-6

#### Node 5: Upload Layer PNG to Storage
- **Type**: Supabase Storage - Upload from URL
- **Bucket**: `layers`
- **Path**: `${record.user_id}/${record.id}/layers/${layer.id}.png`
- **Source URL**: `${layer.image_url}` (from AI response)

#### Node 6: Insert Layer Record
- **Type**: Supabase Insert Row
- **Table**: `project_layers`
- **Data**:
  ```json
  {
    "project_id": "${record.id}",
    "name": "${layer.name}",
    "png_url": "${uploadedPath}",
    "width": "${layer.width}",
    "height": "${layer.height}",
    "z_index": "${loopIndex}",
    "visible": true,
    "bbox": {
      "x": "${layer.bbox.x}",
      "y": "${layer.bbox.y}",
      "width": "${layer.bbox.width}",
      "height": "${layer.bbox.height}"
    },
    "transform": {
      "x": 0,
      "y": 0,
      "scale": 1,
      "rotation": 0,
      "opacity": 1
    }
  }
  ```

#### Node 7: Update Project Status (completed)
- **Type**: Supabase Update Row
- **Table**: `projects`
- **Filter**: `id = record.id`
- **Update**: `{ "status": "completed", "updated_at": "NOW()" }`

#### Error Handler
- **On Error**: Update project status to 'failed'
- **Type**: Supabase Update Row
- **Update**: `{ "status": "failed", "updated_at": "NOW()" }`

---

## Workflow 2: Cleanup Project

### Trigger
- **Type**: Supabase Webhook
- **Table**: `project_layers`
- **Event**: DELETE
- **Schema**: public

### Input (from webhook payload)
```json
{
  "type": "DELETE",
  "table": "project_layers",
  "old_record": {
    "id": "uuid",
    "project_id": "uuid",
    "png_url": "user_id/project_id/layers/layer_id.png"
  }
}
```

### Node Flow

```
[Supabase Trigger]
    → [Delete Layer PNG from Storage]
    → [Return Success]
```

### Node Specifications

#### Node 1: Delete Layer File
- **Type**: Supabase Storage - Delete File
- **Bucket**: `layers`
- **Path**: `old_record.png_url`

#### Node 2: Return Success
- **Type**: Return/Output
- **Value**: `{ "deleted": true, "path": "${old_record.png_url}" }`

---

## Workflow 3: Build Export

### Trigger
- **Type**: Supabase Webhook
- **Table**: `exports`
- **Event**: INSERT
- **Schema**: public

### Input (from webhook payload)
```json
{
  "type": "INSERT",
  "table": "exports",
  "record": {
    "id": "uuid",
    "project_id": "uuid",
    "format": "png",
    "status": "queued"
  }
}
```

### Node Flow

```
[Supabase Trigger]
    → [Update Export Status to 'processing']
    → [Get Project Details]
    → [Get All Visible Layers]
    → [Get Signed URLs for All Layer PNGs]
    → [Call Image Compositing API]
    → [Upload Composite to Storage]
    → [Update Export with Output URL]
    → [Update Export Status to 'completed']
    → [Error Handler: Update Status to 'failed']
```

### Node Specifications

#### Node 1: Update Export Status (processing)
- **Type**: Supabase Update Row
- **Table**: `exports`
- **Filter**: `id = record.id`
- **Update**: `{ "status": "processing" }`

#### Node 2: Get Project
- **Type**: Supabase Select Row
- **Table**: `projects`
- **Filter**: `id = record.project_id`
- **Output**: `project`

#### Node 3: Get Visible Layers
- **Type**: Supabase Select Rows
- **Table**: `project_layers`
- **Filter**: `project_id = record.project_id AND visible = true`
- **Order**: `z_index ASC`
- **Output**: `layers[]`

#### Node 4: Loop - Get Signed URLs
- **Type**: Loop/Iterator
- **Input**: `layers`
- **For Each**: Get signed URL for `layer.png_url`
- **Output**: Array of `{ layer, signedUrl }`

#### Node 5: Composite Layers
- **Type**: HTTP Request (or Sharp/Canvas node)
- **Method**: POST
- **URL**: Image processing API (or custom function)
- **Body**:
  ```json
  {
    "width": "${project.width}",
    "height": "${project.height}",
    "format": "${record.format}",
    "layers": [
      {
        "url": "${layer.signedUrl}",
        "x": "${layer.transform.x}",
        "y": "${layer.transform.y}",
        "scale": "${layer.transform.scale}",
        "rotation": "${layer.transform.rotation}",
        "opacity": "${layer.transform.opacity}"
      }
    ]
  }
  ```
- **Output**: Composited image buffer/URL

#### Node 6: Upload Composite
- **Type**: Supabase Storage - Upload
- **Bucket**: `exports`
- **Path**: `${project.user_id}/${record.project_id}/exports/${record.id}.${record.format}`
- **Content**: Composite image from previous step

#### Node 7: Update Export Record
- **Type**: Supabase Update Row
- **Table**: `exports`
- **Filter**: `id = record.id`
- **Update**: 
  ```json
  {
    "output_url": "${uploadedPath}",
    "status": "completed"
  }
  ```

#### Error Handler
- **On Error**: Update export status to 'failed'

---

## Environment Variables / Secrets

Configure these in BuildShip:

| Secret | Description |
|--------|-------------|
| `SUPABASE_URL` | `https://dbluxquekhkihatcjplz.supabase.co` |
| `SUPABASE_SERVICE_KEY` | Service role key (not anon key) for admin access |
| `FAL_API_KEY` | fal.ai API key for AI layer extraction |

---

## Testing Checklist

### Workflow 1: Run Layering Job
- [ ] Create new project in app → status changes to 'processing'
- [ ] Wait for AI processing → layers appear in `project_layers` table
- [ ] Status changes to 'completed'
- [ ] Layer PNGs visible in `layers` bucket
- [ ] App shows layers in 3D viewer

### Workflow 2: Cleanup Project
- [ ] Delete a layer from app
- [ ] Layer PNG removed from storage bucket
- [ ] No orphaned files remain

### Workflow 3: Build Export
- [ ] Request export from app
- [ ] Export status changes to 'processing'
- [ ] Composite image uploaded to `exports` bucket
- [ ] Export status changes to 'completed'
- [ ] Download link works in app

---

## Notes

1. **Service Key Required**: Workflows need the Supabase service role key to bypass RLS policies when updating records.

2. **AI Model Selection**: The spec uses fal.ai's BiRefNet for layer extraction. Alternatives:
   - Segment Anything (SAM)
   - Remove.bg API
   - Custom trained model

3. **Image Compositing**: For Workflow 3, you may need:
   - Sharp (Node.js library in BuildShip)
   - Canvas API
   - External image processing service
   - Or skip compositing and do it client-side

4. **Error Handling**: Each workflow should update status to 'failed' on errors and optionally log the error message to a `error_message` column.

---

*Phase 9 - BuildShip Workflow Specification*
*Created: 2026-01-25*
