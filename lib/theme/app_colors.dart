import 'package:flutter/material.dart';

/// App color palette inspired by the Layers logo.
///
/// The logo features a deep navy background (#0A1628) with vibrant blue (#1C39EC)
/// and cyan (#00D4FF) gradients. These colors define both light and dark themes.
class AppColors {
  AppColors._();

  // ===========================================================================
  // Light Theme Colors
  // ===========================================================================

  /// Primary: Deep blue from logo gradient start
  static const Color lightPrimary = Color(0xFF1C39EC);

  /// Secondary: Cyan accent glow from logo
  static const Color lightSecondary = Color(0xFF00D4FF);

  /// Background: Pure white
  static const Color lightBackground = Color(0xFFFFFFFF);

  /// Surface: Subtle cool gray for cards and elevated surfaces
  static const Color lightSurface = Color(0xFFF8FAFC);

  /// Surface variant: Slightly darker for differentiation
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);

  /// Primary text: Near-black for high contrast
  static const Color lightOnBackground = Color(0xFF0F172A);

  /// Secondary text: Slate gray for less emphasis
  static const Color lightOnSurfaceVariant = Color(0xFF64748B);

  /// On primary: White text on primary color
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  /// On secondary: Dark text on secondary color
  static const Color lightOnSecondary = Color(0xFF0F172A);

  /// Error: Soft red
  static const Color lightError = Color(0xFFEF4444);

  /// On error: White text on error color
  static const Color lightOnError = Color(0xFFFFFFFF);

  /// Success: Soft green
  static const Color lightSuccess = Color(0xFF10B981);

  /// On success: White text on success color
  static const Color lightOnSuccess = Color(0xFFFFFFFF);

  /// Divider and border colors
  static const Color lightOutline = Color(0xFFE2E8F0);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);

  // ===========================================================================
  // Dark Theme Colors
  // ===========================================================================

  /// Primary: Bright blue - vibrant on dark backgrounds
  static const Color darkPrimary = Color(0xFF3B82F6);

  /// Secondary: Cyan - the logo's signature glow
  static const Color darkSecondary = Color(0xFF22D3EE);

  /// Background: Deep navy - matches logo background
  static const Color darkBackground = Color(0xFF0A1628);

  /// Surface: Slightly lighter navy for cards
  static const Color darkSurface = Color(0xFF111827);

  /// Surface variant: For elevated surfaces and differentiation
  static const Color darkSurfaceVariant = Color(0xFF1E293B);

  /// Primary text: Off-white for readability on dark
  static const Color darkOnBackground = Color(0xFFF1F5F9);

  /// Secondary text: Cool gray for less emphasis
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);

  /// On primary: Dark text on primary color
  static const Color darkOnPrimary = Color(0xFF0F172A);

  /// On secondary: Dark text on secondary color
  static const Color darkOnSecondary = Color(0xFF0F172A);

  /// Error: Soft red (brighter on dark)
  static const Color darkError = Color(0xFFF87171);

  /// On error: Dark text on error color
  static const Color darkOnError = Color(0xFF0F172A);

  /// Success: Soft green (brighter on dark)
  static const Color darkSuccess = Color(0xFF34D399);

  /// On success: Dark text on success color
  static const Color darkOnSuccess = Color(0xFF0F172A);

  /// Divider and border colors
  static const Color darkOutline = Color(0xFF334155);
  static const Color darkOutlineVariant = Color(0xFF475569);

  // ===========================================================================
  // Accent Colors (Shared)
  // ===========================================================================

  /// Cyan glow - used for highlights and special accents
  static const Color cyanGlow = Color(0xFF00D4FF);

  /// Deep blue - primary brand color
  static const Color deepBlue = Color(0xFF1C39EC);

  /// Navy - dark theme foundation
  static const Color navy = Color(0xFF0A1628);
}
