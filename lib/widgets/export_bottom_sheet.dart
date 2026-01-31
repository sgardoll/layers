import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/result.dart';
import '../models/layer.dart';
import '../providers/entitlement_provider.dart';
import '../services/supabase_export_service.dart';
import 'export_purchase_sheet.dart';

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
  ExportJob? _currentExport;
  StreamSubscription<ExportJob>? _exportSubscription;

  @override
  void dispose() {
    _exportSubscription?.cancel();
    super.dispose();
  }

  // TODO: Remove before release - forces purchase sheet for testing
  static const _debugForcePurchaseSheet = false;
  // TODO: Remove before release - skips payment gate entirely for testing exports
  static const _debugSkipPaymentGate = false;

  Future<void> _startExport(ExportType type) async {
    // Debug: skip payment gate entirely for testing export workflow
    if (_debugSkipPaymentGate) {
      debugPrint('DEBUG: Skipping payment gate for export testing');
    } else {
      // Check if user has Pro entitlement
      final revenueCat = ref.read(revenueCatServiceProvider);

      bool isPro = false;
      try {
        isPro = await revenueCat.hasProEntitlement();
      } catch (e) {
        // RevenueCat error - log and treat as non-Pro (will show purchase option)
        debugPrint('RevenueCat entitlement check failed: $e');
      }

      // Debug override for testing purchase flow
      if (_debugForcePurchaseSheet) {
        isPro = false;
      }

      if (!isPro) {
        // Show purchase sheet for non-Pro users
        if (!mounted) return;

        bool purchased = false;
        try {
          purchased = await ExportPurchaseSheet.show(
            context,
            revenueCatService: revenueCat,
          );
        } catch (e) {
          debugPrint('Purchase sheet error: $e');
          _showSnackBar('Could not load purchase options');
          return;
        }

        if (!purchased || !mounted) return;
      }
    }

    setState(() {
      _isExporting = true;
      _statusMessage = 'Starting export...';
    });

    final exportService = ref.read(supabaseExportServiceProvider);

    List<String>? layerIds;
    if (type == ExportType.pngs && widget.selectedLayer != null) {
      layerIds = [widget.selectedLayer!.id];
    }

    final result = await exportService.createExport(
      projectId: widget.projectId,
      type: type,
      layerIds: layerIds,
    );

    result.when(
      success: (export) {
        setState(() {
          _currentExport = export;
          _statusMessage = 'Processing...';
        });
        _subscribeToExport(export.id);
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

  void _subscribeToExport(String exportId) {
    final exportService = ref.read(supabaseExportServiceProvider);

    _exportSubscription?.cancel();
    _exportSubscription = exportService
        .subscribeToExport(exportId)
        .listen(
          (export) {
            setState(() => _currentExport = export);

            if (export.isComplete && export.assetUrl != null) {
              setState(() => _statusMessage = 'Ready to download!');
            } else if (export.isFailed) {
              _showSnackBar(export.errorMessage ?? 'Export failed');
              setState(() {
                _isExporting = false;
                _statusMessage = null;
                _currentExport = null;
              });
            } else if (export.isProcessing) {
              setState(() => _statusMessage = 'Building export...');
            }
          },
          onError: (e) {
            _showSnackBar('Connection error: $e');
            setState(() {
              _isExporting = false;
              _statusMessage = null;
            });
          },
        );
  }

  Future<void> _downloadExport() async {
    final url = _currentExport?.assetUrl;
    if (url == null) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) Navigator.pop(context);
    } else {
      _showSnackBar('Could not open download link');
    }
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
            if (_currentExport?.isComplete == true) ...[
              Icon(
                Icons.check_circle,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Export Ready!',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _downloadExport,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              Text(
                _statusMessage ?? 'Exporting...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ] else ...[
            _ExportOption(
              icon: Icons.image_outlined,
              title: 'Single Layer (PNG)',
              subtitle: widget.selectedLayer != null
                  ? 'Layer ${widget.selectedLayer!.zIndex + 1}'
                  : 'Select a layer first',
              enabled: widget.selectedLayer != null,
              onTap: () => _startExport(ExportType.pngs),
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.folder_zip_outlined,
              title: 'All Layers (ZIP)',
              subtitle: '${widget.layers.length} layers as separate PNGs',
              onTap: () => _startExport(ExportType.zip),
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.layers_outlined,
              title: 'Project Pack (.layers)',
              subtitle: 'Re-importable with all settings',
              onTap: () => _startExport(ExportType.layersPack),
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
