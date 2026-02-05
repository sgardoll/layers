import 'package:flutter/material.dart';

/// Generous, intentional spacing tokens for the Layers design system.
///
/// These values create breathing room and visual hierarchy throughout the app.
/// The scale is based on a 4pt grid system with exponential growth for larger values.
class AppSpacing {
  AppSpacing._();

  /// Micro adjustments (4.0)
  static const double xs = 4.0;

  /// Tight spacing (8.0)
  static const double sm = 8.0;

  /// Standard spacing (16.0)
  static const double md = 16.0;

  /// Section padding (24.0)
  static const double lg = 24.0;

  /// Large sections (32.0)
  static const double xl = 32.0;

  /// Major divisions (48.0)
  static const double xxl = 48.0;

  /// Hero sections (64.0)
  static const double xxxl = 64.0;

  // ===========================================================================
  // EdgeInsets Helpers
  // ===========================================================================

  /// All sides padding with given value
  static EdgeInsets paddingAll(double value) => EdgeInsets.all(value);

  /// Horizontal padding only
  static EdgeInsets paddingHorizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  /// Vertical padding only
  static EdgeInsets paddingVertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  /// Symmetric padding (horizontal and vertical)
  static EdgeInsets paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) => EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Left padding only
  static EdgeInsets paddingLeft(double value) => EdgeInsets.only(left: value);

  /// Right padding only
  static EdgeInsets paddingRight(double value) => EdgeInsets.only(right: value);

  /// Top padding only
  static EdgeInsets paddingTop(double value) => EdgeInsets.only(top: value);

  /// Bottom padding only
  static EdgeInsets paddingBottom(double value) =>
      EdgeInsets.only(bottom: value);

  // ===========================================================================
  // Common Presets
  // ===========================================================================

  /// Standard screen padding (horizontal: md)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: md);

  /// Card padding (all sides: md)
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// List item padding (vertical: sm, horizontal: md)
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    vertical: sm,
    horizontal: md,
  );

  /// Section padding (vertical: lg, horizontal: md)
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    vertical: lg,
    horizontal: md,
  );

  /// Compact padding (all sides: sm)
  static const EdgeInsets compactPadding = EdgeInsets.all(sm);

  /// Large section padding (vertical: xl, horizontal: md)
  static const EdgeInsets largeSectionPadding = EdgeInsets.symmetric(
    vertical: xl,
    horizontal: md,
  );
}
