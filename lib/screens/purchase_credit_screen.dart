import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/credit_transaction.dart';
import '../providers/credits_provider.dart';
import '../providers/entitlement_provider.dart';
import '../widgets/purchase_button.dart';

/// Screen for purchasing export credits.
///
/// Shows the price, handles the purchase flow, and adds credits to the user's balance
/// after a successful purchase. Follows the same patterns as PaywallScreen.
class PurchaseCreditScreen extends ConsumerStatefulWidget {
  const PurchaseCreditScreen({super.key});

  /// Show the purchase screen as a modal bottom sheet.
  /// Returns true if purchase succeeded, false otherwise.
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const PurchaseCreditScreen(),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PurchaseCreditScreen> createState() =>
      _PurchaseCreditScreenState();
}

class _PurchaseCreditScreenState extends ConsumerState<PurchaseCreditScreen> {
  Package? _exportPackage;
  bool _isLoadingPackage = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPackage();
  }

  Future<void> _loadPackage() async {
    final revenueCat = ref.read(revenueCatServiceProvider);
    final package = await revenueCat.getExportPackage();

    if (mounted) {
      setState(() {
        _exportPackage = package;
        _isLoadingPackage = false;
        if (package == null) {
          _errorMessage = 'Export credits are not available at this time.';
        }
      });
    }
  }

  Future<void> _purchaseCredit() async {
    if (_exportPackage == null) return;

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    final revenueCat = ref.read(revenueCatServiceProvider);
    final result = await revenueCat.purchaseExportCredit(_exportPackage!);

    if (!mounted) return;

    if (result.isSuccess) {
      // Add credits to user's balance
      final success = await ref.read(creditsProvider.notifier).addCredits(
            1,
            CreditTransactionType.purchase,
            description:
                'Purchased: ${_exportPackage!.storeProduct.priceString}',
          );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isPurchasing = false;
            _errorMessage =
                'Purchase succeeded but failed to add credits. Please contact support.';
          });
        }
      }
    } else if (result.isCancelled) {
      setState(() => _isPurchasing = false);
    } else {
      setState(() {
        _isPurchasing = false;
        _errorMessage = result.errorMessage ?? 'Purchase failed. Please try again.';
      });
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    final revenueCat = ref.read(revenueCatServiceProvider);
    final result = await revenueCat.restorePurchases();

    if (!mounted) return;

    if (result.isSuccess) {
      // For consumables, we need to check if there are any pending transactions
      // RevenueCat doesn't automatically restore consumables, so we refresh credits
      await ref.read(creditsProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _isPurchasing = false;
        _errorMessage = result.errorMessage ?? 'No purchases to restore';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Export Credit'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with icon
              _buildHeader(context, colorScheme),
              const SizedBox(height: 32),

              // Main content
              if (_isLoadingPackage)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_exportPackage != null)
                _buildPurchaseContent(context, colorScheme)
              else
                _buildErrorState(context),

              const SizedBox(height: 24),

              // Restore purchases button
              if (!_isLoadingPackage)
                TextButton(
                  onPressed: _isPurchasing ? null : _restorePurchases,
                  child: const Text('Restore Purchases'),
                ),

              const SizedBox(height: 16),

              // Legal links
              _buildLegalLinks(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.download_rounded,
            size: 40,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Export Credit',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Get 1 export credit for a one-time layer export',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPurchaseContent(BuildContext context, ColorScheme colorScheme) {
    final priceString = _exportPackage!.storeProduct.priceString;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Price card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                priceString,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'per credit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Benefits list
        _buildBenefitRow(
          Icons.check_circle_outline,
          'Export in any format (PNG, ZIP, .layers)',
        ),
        const SizedBox(height: 12),
        _buildBenefitRow(
          Icons.check_circle_outline,
          'High-resolution layer extraction',
        ),
        const SizedBox(height: 12),
        _buildBenefitRow(
          Icons.star_outline,
          'Or subscribe to Pro for unlimited exports',
        ),
        const SizedBox(height: 32),

        // Purchase button
        PurchaseButton(
          price: priceString,
          onPressed: _purchaseCredit,
          isLoading: _isPurchasing,
          isEnabled: !_isPurchasing,
          label: 'Buy Credit',
          errorMessage: _errorMessage,
        ),
      ],
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unable to load purchase options',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loadPackage,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLinks(BuildContext context, ColorScheme colorScheme) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        children: [
          const TextSpan(text: 'By purchasing, you agree to our '),
          TextSpan(
            text: 'Terms of Use',
            style: TextStyle(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl('https://connectio.com.au/terms/'),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap =
                  () => _launchUrl('https://connectio.com.au/privacy-policy/'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }
}
