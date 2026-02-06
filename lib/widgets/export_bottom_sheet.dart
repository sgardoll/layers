import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/result.dart';
import '../models/layer.dart';
import '../providers/credits_provider.dart';
import '../providers/entitlement_provider.dart';
import '../screens/purchase_credit_screen.dart';
import '../services/supabase_export_service.dart';
import 'credit_indicator.dart';

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

  Future<void> _startExport(ExportType type) async {
    // Check if user has Pro entitlement (Pro users don't consume credits)
    final revenueCat = ref.read(revenueCatServiceProvider);
    final creditsNotifier = ref.read(creditsProvider.notifier);

    bool isPro = false;
    try {
      isPro = await revenueCat.hasProEntitlement();
    } catch (e) {
      debugPrint('RevenueCat entitlement check failed: $e');
    }

    if (!isPro) {
      // Non-Pro users need to check and consume credits
      final hasCredits = ref.read(hasCreditsProvider);

      if (!hasCredits) {
        // No credits - show purchase screen
        if (!mounted) return;

        final purchased = await PurchaseCreditScreen.show(context);

        if (!purchased || !mounted) return;

        // Credit should be added by purchase flow, but refresh to be sure
        await ref.read(creditsProvider.notifier).refresh();
      }

      // Consume credit for export
      final consumed = await creditsNotifier.consumeCredit(
        projectId: widget.projectId,
        description: 'Export: ${widget.projectName}',
      );

      if (!consumed) {
        if (mounted) {
          _showSnackBar('Failed to consume credit. Please try again.');
        }
        return;
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
    _exportSubscription = exportService.subscribeToExport(exportId).listen(
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
    if (url == null) {
      _showSnackBar('No download URL available');
      return;
    }

    try {
      final uri = Uri.parse(url);

      // Try to launch without checking canLaunchUrl first (more reliable on Android)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        if (mounted) Navigator.pop(context);
      } else {
        // Fallback: try with platform default mode
        final fallbackLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );

        if (fallbackLaunched && mounted) {
          Navigator.pop(context);
        } else {
          _showSnackBar('Could not open download link. Please try again.');
        }
      }
    } catch (e) {
      debugPrint('Download launch error: $e');
      _showSnackBar('Could not open download link: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showPurchaseSheet() async {
    try {
      final purchased = await PurchaseCreditScreen.show(context);
      if (purchased) {
        await ref.read(creditsProvider.notifier).refresh();
      }
    } catch (e) {
      debugPrint('Purchase screen error: $e');
      _showSnackBar('Could not load purchase options');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCredits = ref.watch(hasCreditsProvider);
    final isPro = ref.watch(entitlementProvider).isPro;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Export', style: theme.textTheme.headlineSmall),
              ),
              if (!isPro) ...[
                const SizedBox(width: 12),
                CreditIndicator(
                  variant: CreditIndicatorVariant.compact,
                  showPurchaseButton: !hasCredits && !_isExporting,
                  onTap: () => _showPurchaseSheet(),
                ),
              ],
            ],
          ),
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
