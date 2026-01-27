import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenuecat_service.dart';

/// Bottom sheet for purchasing a single export credit.
///
/// Shows the price and handles the purchase flow for non-Pro users.
class ExportPurchaseSheet extends StatefulWidget {
  final RevenueCatService revenueCatService;
  final VoidCallback onPurchaseSuccess;
  final VoidCallback onCancel;

  const ExportPurchaseSheet({
    super.key,
    required this.revenueCatService,
    required this.onPurchaseSuccess,
    required this.onCancel,
  });

  /// Show the purchase sheet and return true if purchase succeeded.
  static Future<bool> show(
    BuildContext context, {
    required RevenueCatService revenueCatService,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      builder: (_) => ExportPurchaseSheet(
        revenueCatService: revenueCatService,
        onPurchaseSuccess: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }

  @override
  State<ExportPurchaseSheet> createState() => _ExportPurchaseSheetState();
}

class _ExportPurchaseSheetState extends State<ExportPurchaseSheet> {
  Package? _exportPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPackage();
  }

  Future<void> _loadPackage() async {
    final package = await widget.revenueCatService.getExportPackage();
    if (mounted) {
      setState(() {
        _exportPackage = package;
        _isLoading = false;
        if (package == null) {
          _errorMessage = 'Export purchase not available';
        }
      });
    }
  }

  Future<void> _purchase() async {
    if (_exportPackage == null) return;

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    final result = await widget.revenueCatService.purchaseExportCredit(
      _exportPackage!,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      widget.onPurchaseSuccess();
    } else if (result.isCancelled) {
      setState(() => _isPurchasing = false);
    } else {
      setState(() {
        _isPurchasing = false;
        _errorMessage = result.errorMessage ?? 'Purchase failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.download_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Export This Project',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            if (_isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_exportPackage != null) ...[
              // Price card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _exportPackage!.storeProduct.priceString,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'One-time purchase',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Benefits
              _BenefitRow(
                icon: Icons.check_circle_outline,
                text: 'Download in any format',
              ),
              const SizedBox(height: 8),
              _BenefitRow(
                icon: Icons.check_circle_outline,
                text: 'High-resolution export',
              ),
              const SizedBox(height: 8),
              _BenefitRow(
                icon: Icons.star_outline,
                text: 'Or subscribe to Pro for unlimited exports',
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Purchase button
              FilledButton(
                onPressed: _isPurchasing ? null : _purchase,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _isPurchasing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Purchase Export'),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button
              TextButton(
                onPressed: _isPurchasing ? null : widget.onCancel,
                child: const Text('Cancel'),
              ),
            ] else ...[
              // Error state
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Unable to load purchase options',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Close'),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
