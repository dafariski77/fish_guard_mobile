import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_radius.dart';

/// Complete application theme configuration for FishGuard.
/// Bridges Material 3 and Apple HIG Cupertino aesthetics into a unified experience.
abstract final class AppTheme {
  /// Primary Light Theme (Default for wet-market shopping)
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(AppColors.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.canvas,
      cardColor: AppColors.card,

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.textInverse,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primary,
        onSecondary: AppColors.textInverse,
        error: AppColors.verdictAvoid,
        onError: AppColors.textInverse,
        errorContainer: AppColors.verdictAvoidBg,
        onErrorContainer: AppColors.verdictAvoid,
        surface: AppColors.card,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.groupedBackground,
        outline: AppColors.border,
        outlineVariant: AppColors.separator,
      ),

      textTheme: textTheme,

      // App Bar Theme: Apple HIG collapsing / transparent style
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: AppTypography.headline(color: AppColors.textPrimary),
      ),

      // Elevated Button: Primary wet-market CTA (54 pt, 12 pt squircle)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          minimumSize: const Size.fromHeight(AppSpacing.primaryButtonHeight),
          padding: AppSpacing.buttonPadding,
          elevation: 0,
          shape: AppRadius.buttonShape(),
          textStyle: AppTypography.headline(color: AppColors.textInverse),
        ),
      ),

      // Outlined Button: Secondary actions ("Report Wrong Species")
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(AppSpacing.primaryButtonHeight),
          padding: AppSpacing.buttonPadding,
          elevation: 0,
          side: const BorderSide(color: AppColors.border, width: 1.0),
          shape: AppRadius.buttonShape(),
          textStyle: AppTypography.headline(color: AppColors.textPrimary),
        ),
      ),

      // Text Button: Skip & Info links
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          textStyle: AppTypography.subheadline(color: AppColors.primary),
        ),
      ),

      // Card Theme: 16 pt squircle, clean white surface, hairline border
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: AppRadius.cardShape(side: const BorderSide(color: AppColors.border, width: 0.8)),
      ),

      // Modal Bottom Sheet: 20 pt top squircle corners
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: AppRadius.sheetShape,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
      ),

      // Divider Theme: 0.5 pt hairline
      dividerTheme: const DividerThemeData(
        color: AppColors.separator,
        thickness: 0.5,
        space: 0.5,
      ),
    );
  }

  /// Cupertino Theme Data for native Apple widgets & navigation controllers
  static CupertinoThemeData get cupertinoTheme {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      primaryContrastingColor: AppColors.textInverse,
      barBackgroundColor: AppColors.canvas.withAlpha(235),
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: CupertinoTextThemeData(
        textStyle: AppTypography.body(),
        actionTextStyle: AppTypography.headline(color: AppColors.primary),
        navTitleTextStyle: AppTypography.headline(),
        navLargeTitleTextStyle: AppTypography.largeTitle(),
      ),
    );
  }
}

/// Convenience extensions on BuildContext for quick token access:
/// `context.colors`, `context.typography`, `context.isDark`
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
