import 'package:flutter/material.dart';

/// Breakpoint definitions for responsive design.
///
/// Mobile: < 600px (phones in portrait)
/// Tablet: 600px - 900px (tablets, phones in landscape)
/// Desktop: > 900px (large tablets, desktop)
class Breakpoints {
  Breakpoints._();

  /// Mobile breakpoint threshold
  static const double mobile = 600;

  /// Tablet breakpoint threshold
  static const double tablet = 900;

  /// Returns true if width is mobile (< 600)
  static bool isMobile(double width) => width < mobile;

  /// Returns true if width is tablet (600-900)
  static bool isTablet(double width) => width >= mobile && width <= tablet;

  /// Returns true if width is desktop (> 900)
  static bool isDesktop(double width) => width > tablet;

  /// Returns the current breakpoint category as a string
  static String getBreakpoint(double width) {
    if (isMobile(width)) return 'mobile';
    if (isTablet(width)) return 'tablet';
    return 'desktop';
  }
}

/// Extension on BuildContext for easy breakpoint access
extension ResponsiveContext on BuildContext {
  /// Get the current screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get the current screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns true if current width is mobile
  bool get isMobile => Breakpoints.isMobile(screenWidth);

  /// Returns true if current width is tablet
  bool get isTablet => Breakpoints.isTablet(screenWidth);

  /// Returns true if current width is desktop
  bool get isDesktop => Breakpoints.isDesktop(screenWidth);
}

/// A widget that builds different layouts based on screen size.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Builder for mobile layout (< 600px)
  final WidgetBuilder? mobile;

  /// Builder for tablet layout (600px - 900px)
  final WidgetBuilder? tablet;

  /// Builder for desktop layout (> 900px)
  final WidgetBuilder? desktop;

  const ResponsiveLayout({super.key, this.mobile, this.tablet, this.desktop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (Breakpoints.isDesktop(width) && desktop != null) {
          return desktop!(context);
        }

        if (Breakpoints.isTablet(width) && tablet != null) {
          return tablet!(context);
        }

        // Mobile is the default fallback
        if (mobile != null) {
          return mobile!(context);
        }

        // If no mobile builder provided, try tablet, then desktop
        if (tablet != null) {
          return tablet!(context);
        }

        if (desktop != null) {
          return desktop!(context);
        }

        throw FlutterError(
          'ResponsiveLayout requires at least one builder (mobile, tablet, or desktop)',
        );
      },
    );
  }
}

/// A widget that shows different child widgets based on screen size.
///
/// Similar to ResponsiveLayout but takes Widgets directly instead of builders.
class ResponsiveVisibility extends StatelessWidget {
  /// Widget to show on mobile (< 600px)
  final Widget? mobile;

  /// Widget to show on tablet (600px - 900px)
  final Widget? tablet;

  /// Widget to show on desktop (> 900px)
  final Widget? desktop;

  const ResponsiveVisibility({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (Breakpoints.isDesktop(width) && desktop != null) {
          return desktop!;
        }

        if (Breakpoints.isTablet(width) && tablet != null) {
          return tablet!;
        }

        if (mobile != null) {
          return mobile!;
        }

        if (tablet != null) {
          return tablet!;
        }

        if (desktop != null) {
          return desktop!;
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Helper functions for responsive values
class ResponsiveValue {
  ResponsiveValue._();

  /// Returns a value based on the current breakpoint
  ///
  /// Usage:
  /// ```dart
  /// final padding = ResponsiveValue.get(
  ///   context: context,
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  static T get<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (Breakpoints.isDesktop(width) && desktop != null) {
      return desktop;
    }

    if (Breakpoints.isTablet(width) && tablet != null) {
      return tablet;
    }

    return mobile;
  }
}
