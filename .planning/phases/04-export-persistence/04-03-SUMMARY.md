# 04-03 Summary: Cleanup Deprecated Services

## Completed: 2026-01-24
## Commit: a5a1a99

## What Was Removed

### Deprecated Services (Deleted)
- `lib/services/layer_service.dart` - REST API client for old backend
- `lib/services/export_service.dart` - Replaced by `supabase_export_service.dart`
- `lib/services/project_repository.dart` - Replaced by `supabase_project_service.dart`

### Deprecated Providers (Deleted)
- `lib/providers/job_provider.dart` - Replaced by `project_provider.dart`
  - `JobNotifier`, `JobState`, `jobProvider` - no longer needed
  - `currentProjectProvider` moved to `project_provider.dart`

## What Was Updated

### ProcessingIndicator (`lib/widgets/processing_indicator.dart`)
**Before**: Used `jobProvider` which polled REST backend for job status
**After**: Uses `projectListProvider` to read project status from Supabase realtime

Changes:
- Now requires `projectId` parameter
- Reads project status from `projectListProvider`
- Status values: queued, processing, ready, failed
- No more polling - uses Supabase realtime subscriptions

## Migration Summary

| Old (REST) | New (Supabase) |
|------------|----------------|
| `LayerService` | `SupabaseProjectService` |
| `ExportService` | `SupabaseExportService` |
| `ProjectRepository` | `SupabaseProjectService` |
| `JobNotifier` | `ProjectListNotifier` |
| `jobProvider` | `projectListProvider` |
| Polling for status | Realtime subscriptions |

## Architecture After Cleanup

```
lib/
├── providers/
│   ├── project_provider.dart      # ProjectListNotifier + currentProjectProvider
│   └── supabase_providers.dart    # Service providers
├── services/
│   ├── supabase_project_service.dart
│   └── supabase_export_service.dart
└── widgets/
    └── processing_indicator.dart  # Uses project status from Supabase
```

## Breaking Changes
- Any code importing `job_provider.dart` must migrate to `project_provider.dart`
- `ProcessingIndicator` now requires `projectId` parameter
- `ProcessingOverlay` now requires `projectId` parameter (nullable)
