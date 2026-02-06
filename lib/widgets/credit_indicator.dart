import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/credits_provider.dart';

/// Variant of the credit indicator display
enum CreditIndicatorVariant {
  /// Compact display: just icon + count
  compact,

  /// Expanded display: icon + count + "credits" label
  expanded,
}

/// A reusable widget to display the user's current credit balance.
///
/// Shows a chip/badge with coin icon and credit count.
/// Handles loading states and zero credits gracefully.
class CreditIndicator extends ConsumerWidget {
  final CreditIndicatorVariant variant;
  final VoidCallback? onTap;
  final bool showPurchaseButton;

  const CreditIndicator({
    super.key,
    this.variant = CreditIndicatorVariant.compact,
    this.onTap,
    this.showPurchaseButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(creditsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Loading state
    if (credits.isLoading) {
      return _buildLoadingState(context, colorScheme);
    }

    // Zero credits with purchase button
    if (credits.creditsRemaining == 0 && showPurchaseButton) {
      return _buildZeroCreditsWithButton(context, colorScheme);
    }

    // Normal display
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(colorScheme, credits.creditsRemaining),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBorderColor(colorScheme, credits.creditsRemaining),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: variant == CreditIndicatorVariant.compact ? 18 : 20,
              color: _getIconColor(colorScheme, credits.creditsRemaining),
            ),
            const SizedBox(width: 6),
            Text(
              '${credits.creditsRemaining}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getTextColor(colorScheme, credits.creditsRemaining),
              ),
            ),
            if (variant == CreditIndicatorVariant.expanded) ...[
              const SizedBox(width: 4),
              Text(
                credits.creditsRemaining == 1 ? 'credit' : 'credits',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: variant == CreditIndicatorVariant.compact ? 50 : 80,
        height: 20,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZeroCreditsWithButton(
      BuildContext context, ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_circle_outline, size: 18),
      label: const Text('Get Credits'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme, int credits) {
    if (credits == 0) {
      return colorScheme.errorContainer.withAlpha(128);
    }
    if (credits <= 2) {
      return colorScheme.primaryContainer.withAlpha(179);
    }
    return colorScheme.primaryContainer.withAlpha(128);
  }

  Color _getBorderColor(ColorScheme colorScheme, int credits) {
    if (credits == 0) {
      return colorScheme.error;
    }
    if (credits <= 2) {
      return colorScheme.primary;
    }
    return colorScheme.outline.withAlpha(128);
  }

  Color _getIconColor(ColorScheme colorScheme, int credits) {
    if (credits == 0) {
      return colorScheme.error;
    }
    return colorScheme.primary;
  }

  Color _getTextColor(ColorScheme colorScheme, int credits) {
    if (credits == 0) {
      return colorScheme.error;
    }
    return colorScheme.onPrimaryContainer;
  }
}

/// A sliver version of CreditIndicator for use in app bars.
class CreditIndicatorSliver extends ConsumerWidget {
  final VoidCallback? onTap;

  const CreditIndicatorSliver({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreditIndicator(
      variant: CreditIndicatorVariant.compact,
      onTap: onTap,
      showPurchaseButton: false,
    );
  }
}
