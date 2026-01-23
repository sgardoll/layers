import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/project_provider.dart';

/// Shows processing status for a specific project.
/// Uses the project's status field which is updated via Supabase realtime.
class ProcessingIndicator extends ConsumerWidget {
  final String projectId;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const ProcessingIndicator({
    super.key,
    required this.projectId,
    this.onCancel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectListProvider);
    final project = projectState.projects
        .where((p) => p.id == projectId)
        .firstOrNull;

    if (project == null) {
      return const SizedBox.shrink();
    }

    final isWorking =
        project.status == 'queued' || project.status == 'processing';
    final isFailed = project.status == 'failed';

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWorking) ...[
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              project.status == 'queued'
                  ? 'Queued for processing...'
                  : 'Processing layers...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              project.status == 'queued'
                  ? 'Waiting in queue'
                  : 'This may take 15-30 seconds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 24),
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
            ],
          ] else if (isFailed) ...[
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Processing failed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to extract layers from this image',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onRetry, child: const Text('Try Again')),
            ],
          ],
        ],
      ),
    );
  }
}

/// Overlay that shows processing status while allowing the child to remain visible.
class ProcessingOverlay extends ConsumerWidget {
  final String? projectId;
  final Widget child;
  final VoidCallback? onCancel;

  const ProcessingOverlay({
    super.key,
    this.projectId,
    required this.child,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (projectId == null) {
      return child;
    }

    final projectState = ref.watch(projectListProvider);
    final project = projectState.projects
        .where((p) => p.id == projectId)
        .firstOrNull;
    final isWorking =
        project != null &&
        (project.status == 'queued' || project.status == 'processing');

    return Stack(
      children: [
        child,
        if (isWorking)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: ProcessingIndicator(
                    projectId: projectId!,
                    onCancel: onCancel,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
