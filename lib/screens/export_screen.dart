import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/supabase_export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const ExportScreen({super.key, this.projectId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  List<ExportJob> _exports = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadExports();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadExports() async {
    setState(() => _isLoading = true);

    final exportService = ref.read(supabaseExportServiceProvider);

    // Load all exports if no projectId, otherwise filter by project
    final result = widget.projectId != null
        ? await exportService.listExports(widget.projectId!)
        : await exportService.listAllExports();

    result.when(
      success: (exports) {
        setState(() {
          _exports = exports;
          _isLoading = false;
          _error = null;
        });
        _subscribeToUpdates();
      },
      failure: (error, _) {
        setState(() {
          _isLoading = false;
          _error = error;
        });
      },
    );
  }

  void _subscribeToUpdates() {
    if (widget.projectId == null) return;

    // Subscribe to each export's status changes
    for (final export in _exports.where((e) => e.isProcessing)) {
      final exportService = ref.read(supabaseExportServiceProvider);
      exportService.subscribeToExport(export.id).listen((updated) {
        setState(() {
          final index = _exports.indexWhere((e) => e.id == updated.id);
          if (index != -1) {
            _exports[index] = updated;
          }
        });
      });
    }
  }

  Future<void> _downloadExport(ExportJob export) async {
    if (export.assetUrl == null) return;

    final uri = Uri.parse(export.assetUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open download link');
    }
  }

  Future<void> _deleteExport(ExportJob export) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Export?'),
        content: const Text('This will permanently delete this export.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final exportService = ref.read(supabaseExportServiceProvider);
    final result = await exportService.deleteExport(export.id);

    result.when(
      success: (_) {
        setState(() {
          _exports.removeWhere((e) => e.id == export.id);
        });
        _showSnackBar('Export deleted');
      },
      failure: (error, _) {
        _showSnackBar('Failed to delete: $error');
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExports,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(_error!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadExports, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_exports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ios_share_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              'No Exports Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Export your layers as PNG, ZIP, or .layers pack',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _exports.length,
        itemBuilder: (context, index) => _ExportCard(
          export: _exports[index],
          onDownload: () => _downloadExport(_exports[index]),
          onDelete: () => _deleteExport(_exports[index]),
        ),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final ExportJob export;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _ExportCard({
    required this.export,
    required this.onDownload,
    required this.onDelete,
  });

  IconData get _typeIcon {
    switch (export.type) {
      case ExportType.pngs:
        return Icons.image_outlined;
      case ExportType.zip:
        return Icons.folder_zip_outlined;
      case ExportType.layersPack:
        return Icons.layers_outlined;
    }
  }

  String get _typeName {
    switch (export.type) {
      case ExportType.pngs:
        return 'PNG';
      case ExportType.zip:
        return 'ZIP';
      case ExportType.layersPack:
        return '.layers';
    }
  }

  Color _statusColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (export.isComplete) return colors.primary;
    if (export.isFailed) return colors.error;
    return colors.tertiary;
  }

  String get _statusText {
    if (export.isComplete) return 'Ready';
    if (export.isFailed) return 'Failed';
    return 'Processing...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_typeIcon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_typeName Export', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _statusColor(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(export.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (export.isFailed && export.errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      export.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (export.isComplete && export.assetUrl != null)
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: onDownload,
                tooltip: 'Download',
              ),
            if (export.isProcessing)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
