import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography design tokens based on the Apple HIG Type Ramp with Inter / SF Pro font metrics.
/// Supports accessibility scaling via MediaQuery.textScalerOf(context).
abstract final class AppTypography {
  // Base font family helper
  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0.0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height / fontSize,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // --- HIG Type Scale ---
  /// Large Title: 34 pt / Bold (700) - Collapsing screen header
  static TextStyle largeTitle({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w700,
        height: 41.0,
        letterSpacing: 0.37,
        color: color,
      );

  /// Title 1: 28 pt / Bold (700) - Verdict Hero ("Safe to Buy", "Do Not Buy")
  static TextStyle title1({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        height: 34.0,
        letterSpacing: 0.36,
        color: color,
      );

  /// Title 2: 22 pt / Bold (700) - Section headers, card titles
  static TextStyle title2({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        height: 28.0,
        letterSpacing: 0.35,
        color: color,
      );

  /// Title 3: 20 pt / SemiBold (600) - Modal sheet headers ("Quick Sensory Check")
  static TextStyle title3({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        height: 25.0,
        letterSpacing: 0.38,
        color: color,
      );

  /// Headline: 17 pt / SemiBold (600) - Primary buttons, fish species names, active headers
  static TextStyle headline({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
        height: 22.0,
        letterSpacing: -0.41,
        color: color,
      );

  /// Body: 17 pt / Regular (400) - Explainability bullets, First-Aid paragraphs
  static TextStyle body({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w400,
        height: 22.0,
        letterSpacing: -0.41,
        color: color,
      );

  /// Body SemiBold: 17 pt / SemiBold (600)
  static TextStyle bodySemiBold({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
        height: 22.0,
        letterSpacing: -0.41,
        color: color,
      );

  /// Callout: 16 pt / Medium (500) - Viewfinder prompts & toasts
  static TextStyle callout({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        height: 21.0,
        letterSpacing: -0.32,
        color: color,
      );

  /// Subheadline: 15 pt / Regular (400) - Secondary metadata, sensory chip labels
  static TextStyle subheadline({Color color = AppColors.textSecondary}) => _baseStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        height: 20.0,
        letterSpacing: -0.24,
        color: color,
      );

  /// Subheadline SemiBold: 15 pt / SemiBold (600) - Chip labels when selected
  static TextStyle subheadlineSemiBold({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        height: 20.0,
        letterSpacing: -0.24,
        color: color,
      );

  /// Footnote: 13 pt / Regular (400) - Timestamps, "AI Screening Tool — Not a Lab Test"
  static TextStyle footnote({Color color = AppColors.textSecondary}) => _baseStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        height: 18.0,
        letterSpacing: -0.08,
        color: color,
      );

  /// Footnote SemiBold: 13 pt / SemiBold (600) - Small badge text
  static TextStyle footnoteSemiBold({Color color = AppColors.textPrimary}) => _baseStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        height: 18.0,
        letterSpacing: -0.08,
        color: color,
      );

  /// Caption 1: 12 pt / Medium (500) - Micro status badges, metric labels
  static TextStyle caption1({Color color = AppColors.textSecondary}) => _baseStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        height: 16.0,
        letterSpacing: 0.0,
        color: color,
      );

  /// Caption 2: 11 pt / Regular (400) - Camera ISO/Flash micro labels
  static TextStyle caption2({Color color = AppColors.textTertiary}) => _baseStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w400,
        height: 14.0,
        letterSpacing: 0.06,
        color: color,
      );

  /// Builds a complete Material TextTheme mapped to the HIG Type Ramp.
  static TextTheme createTextTheme([Color color = AppColors.textPrimary]) {
    return TextTheme(
      displayLarge: largeTitle(color: color),
      displayMedium: title1(color: color),
      displaySmall: title2(color: color),
      headlineMedium: title3(color: color),
      headlineSmall: headline(color: color),
      titleLarge: headline(color: color),
      titleMedium: callout(color: color),
      titleSmall: subheadline(color: color),
      bodyLarge: body(color: color),
      bodyMedium: subheadline(color: color),
      bodySmall: footnote(color: color),
      labelLarge: headline(color: color),
      labelMedium: subheadline(color: color),
      labelSmall: caption1(color: color),
    );
  }
}
