# 04-02 Summary: Project Gallery

## Completed: 2026-01-24
## Commit: 4e407fc

## What Was Built

### 1. ProjectProvider (`lib/providers/project_provider.dart`)
- `ProjectListState` with status enum (initial/loading/loaded/error)
- `ProjectListNotifier` extending `Notifier<ProjectListState>`
- Methods: `loadProjects()`, `createProject(File)`, `deleteProject(id)`
- Realtime subscriptions for projects in processing status
- Auto-updates when project status changes (queued → processing → ready)

### 2. ProjectScreen (`lib/screens/project_screen.dart`)
- Grid gallery with 2-column layout
- Project cards showing:
  - Thumbnail from source image
  - Project name
  - Status badge (color-coded: queued=orange, processing=blue, ready=green, failed=red)
  - Delete action in popup menu
- Empty state with call-to-action
- FAB to create new project (image_picker integration)
- Pull-to-refresh
- Navigation to LayersScreen on tap

### 3. Model Update (`lib/models/project.dart`)
- Added `status` field (String, default: 'queued')
- Valid values: queued, processing, ready, failed
- Regenerated freezed code

### 4. Service Update (`lib/services/supabase_project_service.dart`)
- Removed duplicate provider definition (now only in supabase_providers.dart)

## Architecture

```
ProjectScreen
    ↓ watches
projectListProvider (ProjectListNotifier)
    ↓ uses
SupabaseProjectService
    ↓ talks to
Supabase (projects table + storage)
```

## Realtime Flow
1. User creates project → INSERT to projects table (status: queued)
2. BuildShip workflow triggered → updates status to processing
3. AI inference completes → updates status to ready + adds layers
4. ProjectListNotifier receives realtime update → UI refreshes automatically

## Files Changed
- `lib/providers/project_provider.dart` (NEW)
- `lib/screens/project_screen.dart` (REWRITTEN)
- `lib/models/project.dart` (status field added)
- `lib/services/supabase_project_service.dart` (removed duplicate provider)
