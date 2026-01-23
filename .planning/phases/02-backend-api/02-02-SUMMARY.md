# 02-02 Summary: Flutter API Client Integration

## Completed

### Flutter Client Files
| File | Purpose |
|------|---------|
| `lib/services/layer_service.dart` | API client: submit jobs, poll status, parse layers |
| `lib/providers/job_provider.dart` | Riverpod state: JobState, JobNotifier, polling logic |
| `lib/widgets/processing_indicator.dart` | UI: progress display during inference |

### LayerService API
```dart
submitJob(File imageFile) -> Result<String, String>  // Returns job ID
getJobStatus(String jobId) -> Result<JobStatus, String>
pollUntilComplete(String jobId) -> Result<List<Layer>, String>
cancelJob(String jobId) -> Result<void, String>
```

### JobProvider State Machine
```
initial -> submitting -> polling -> completed/failed
                    \-> cancelled
```

### ProcessingIndicator Widget
- Animated progress indicator
- Status text display
- Cancel button
- Error state with retry option

### Integration Pattern
```dart
// In screen:
final jobState = ref.watch(jobProvider);
jobState.when(
  initial: () => ImportButton(),
  submitting: () => ProcessingIndicator(status: 'Uploading...'),
  polling: (progress) => ProcessingIndicator(progress: progress),
  completed: (layers) => LayersView(layers: layers),
  failed: (error) => ErrorRetry(error: error),
);
```

## Verification
- `flutter analyze`: No issues
- LSP diagnostics: Clean on all 3 files
