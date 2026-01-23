import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layer.dart';
import '../services/export_service.dart';

class ExportBottomSheet extends ConsumerStatefulWidget {
  final List<Layer> layers;
  final String projectName;
  final String projectId;
  final Layer? selectedLayer;

  const ExportBottomSheet({
    super.key,
    required this.layers,
    required this.projectName,
    required this.projectId,
    this.selectedLayer,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Layer> layers,
    required String projectName,
    required String projectId,
    Layer? selectedLayer,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => ExportBottomSheet(
        layers: layers,
        projectName: projectName,
        projectId: projectId,
        selectedLayer: selectedLayer,
      ),
    );
  }

  @override
  ConsumerState<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends ConsumerState<ExportBottomSheet> {
  bool _isExporting = false;
  String? _statusMessage;

  Future<void> _exportSinglePng() async {
    if (widget.selectedLayer == null) {
      _showSnackBar('Select a layer first');
      return;
    }

    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting PNG...';
    });

    final exportService = ref.read(exportServiceProvider);
    final result = await exportService.exportLayerAsPng(
      widget.selectedLayer!,
      projectName: widget.projectName,
    );

    result.when(
      success: (file) async {
        await exportService.shareFile(file);
        if (mounted) Navigator.pop(context);
      },
      failure: (error, _) {
        _showSnackBar(error);
        setState(() {
          _isExporting = false;
          _statusMessage = null;
        });
      },
    );
  }

  Future<void> _exportAllAsZip() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Creating ZIP...';
    });

    final exportService = ref.read(exportServiceProvider);
    final result = await exportService.exportAllLayersAsZip(
      widget.layers,
      projectName: widget.projectName,
    );

    result.when(
      success: (file) async {
        await exportService.shareFile(file);
        if (mounted) Navigator.pop(context);
      },
      failure: (error, _) {
        _showSnackBar(error);
        setState(() {
          _isExporting = false;
          _statusMessage = null;
        });
      },
    );
  }

  Future<void> _exportAsLayersPack() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Creating .layers pack...';
    });

    final exportService = ref.read(exportServiceProvider);
    final result = await exportService.exportAsLayersPack(
      widget.layers,
      projectName: widget.projectName,
      projectId: widget.projectId,
    );

    result.when(
      success: (file) async {
        await exportService.shareFile(file);
        if (mounted) Navigator.pop(context);
      },
      failure: (error, _) {
        _showSnackBar(error);
        setState(() {
          _isExporting = false;
          _statusMessage = null;
        });
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Export', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          if (_isExporting) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            Text(
              _statusMessage ?? 'Exporting...',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ] else ...[
            _ExportOption(
              icon: Icons.image_outlined,
              title: 'Single Layer (PNG)',
              subtitle: widget.selectedLayer != null
                  ? 'Layer ${widget.selectedLayer!.zIndex}'
                  : 'Select a layer first',
              enabled: widget.selectedLayer != null,
              onTap: _exportSinglePng,
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.folder_zip_outlined,
              title: 'All Layers (ZIP)',
              subtitle: '${widget.layers.length} layers as separate PNGs',
              onTap: _exportAllAsZip,
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.layers_outlined,
              title: 'Project Pack (.layers)',
              subtitle: 'Re-importable with all settings',
              onTap: _exportAsLayersPack,
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: enabled
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainerHighest.withAlpha(128),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(128),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: enabled
                            ? null
                            : theme.colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: enabled
                    ? theme.colorScheme.onSurface.withAlpha(128)
                    : theme.colorScheme.onSurface.withAlpha(64),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
