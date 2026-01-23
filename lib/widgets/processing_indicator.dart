import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/job_provider.dart';

class ProcessingIndicator extends ConsumerWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const ProcessingIndicator({super.key, this.onCancel, this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(jobProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (jobState.isWorking) ...[
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              jobState.isUploading
                  ? 'Uploading image...'
                  : 'Processing layers...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              jobState.isUploading
                  ? 'Sending to AI'
                  : 'This may take 15-30 seconds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 24),
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
            ],
          ] else if (jobState.isFailed) ...[
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
              jobState.error ?? 'Unknown error',
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

class ProcessingOverlay extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onCancel;

  const ProcessingOverlay({super.key, required this.child, this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(jobProvider);

    return Stack(
      children: [
        child,
        if (jobState.isWorking)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Card(child: ProcessingIndicator(onCancel: onCancel)),
              ),
            ),
          ),
      ],
    );
  }
}
