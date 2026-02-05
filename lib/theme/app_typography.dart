import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system using Inter font family for a distinctive, modern look.
///
/// The typography scale provides clear hierarchy with generous sizing and
/// appropriate letter spacing for both light and dark themes.
class AppTypography {
  AppTypography._();

  // ===========================================================================
  // Font Family
  // ===========================================================================

  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  // ===========================================================================
  // Text Styles - Light Theme
  // ===========================================================================

  static TextStyle get lightDisplayLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.lightOnBackground,
    height: 1.2,
  );

  static TextStyle get lightDisplayMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: AppColors.lightOnBackground,
    height: 1.3,
  );

  static TextStyle get lightHeadlineLarge => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: AppColors.lightOnBackground,
    height: 1.4,
  );

  static TextStyle get lightHeadlineMedium => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: AppColors.lightOnBackground,
    height: 1.4,
  );

  static TextStyle get lightBodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.lightOnBackground,
    height: 1.5,
  );

  static TextStyle get lightBodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.lightOnBackground,
    height: 1.5,
  );

  static TextStyle get lightBodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.lightOnSurfaceVariant,
    height: 1.5,
  );

  static TextStyle get lightLabelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.lightOnBackground,
    height: 1.4,
  );

  static TextStyle get lightLabelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.lightOnSurfaceVariant,
    height: 1.4,
  );

  // ===========================================================================
  // Text Styles - Dark Theme
  // ===========================================================================

  static TextStyle get darkDisplayLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.darkOnBackground,
    height: 1.2,
  );

  static TextStyle get darkDisplayMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: AppColors.darkOnBackground,
    height: 1.3,
  );

  static TextStyle get darkHeadlineLarge => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: AppColors.darkOnBackground,
    height: 1.4,
  );

  static TextStyle get darkHeadlineMedium => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: AppColors.darkOnBackground,
    height: 1.4,
  );

  static TextStyle get darkBodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.darkOnBackground,
    height: 1.5,
  );

  static TextStyle get darkBodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.darkOnBackground,
    height: 1.5,
  );

  static TextStyle get darkBodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.darkOnSurfaceVariant,
    height: 1.5,
  );

  static TextStyle get darkLabelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.darkOnBackground,
    height: 1.4,
  );

  static TextStyle get darkLabelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.darkOnSurfaceVariant,
    height: 1.4,
  );

  // ===========================================================================
  // Material Text Theme
  // ===========================================================================

  static TextTheme textTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return TextTheme(
      displayLarge: isLight ? lightDisplayLarge : darkDisplayLarge,
      displayMedium: isLight ? lightDisplayMedium : darkDisplayMedium,
      headlineLarge: isLight ? lightHeadlineLarge : darkHeadlineLarge,
      headlineMedium: isLight ? lightHeadlineMedium : darkHeadlineMedium,
      bodyLarge: isLight ? lightBodyLarge : darkBodyLarge,
      bodyMedium: isLight ? lightBodyMedium : darkBodyMedium,
      bodySmall: isLight ? lightBodySmall : darkBodySmall,
      labelLarge: isLight ? lightLabelLarge : darkLabelLarge,
      labelMedium: isLight ? lightLabelMedium : darkLabelMedium,
    );
  }
}
