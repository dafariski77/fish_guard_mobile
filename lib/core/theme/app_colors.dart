import 'package:material_ui/material_ui.dart';

/// Semantic color tokens for FishGuard based on the v3.0 Apple HIG & Modern Minimalist UI.
/// Zero raw hex codes in feature widgets: all UI elements reference these tokens.
abstract final class AppColors {
  // --- Brand / Primary Accents ---
  /// Ocean Teal - Primary CTA, active icons, interactive highlights
  static const Color primary = Color(0xFF007A87);
  /// Light Ocean Teal tint - active chip fills, subtle highlights
  static const Color primaryLight = Color(0xFFE0F2F1);
  /// Deep Teal - pressed state, dark mode accents
  static const Color primaryDark = Color(0xFF005A64);

  // --- Surfaces & Backgrounds ---
  /// Canvas background behind grouped lists (Apple systemGroupedBackground equivalent)
  static const Color groupedBackground = Color(0xFFF2F2F7);
  /// Clean modern canvas fallback
  static const Color canvas = Color(0xFFF8F9FA);
  /// Inset card surface, sheets, bottom navigation surface
  static const Color card = Color(0xFFFFFFFF);
  /// Secondary surface (subtle contrast card or inset item)
  static const Color cardSecondary = Color(0xFFF8FAFC);

  // --- Text Colors (High Contrast / WCAG AAA for wet-market lighting) ---
  /// Primary titles, species names, verdict headers (Apple label)
  static const Color textPrimary = Color(0xFF111827);
  /// Timestamps, secondary subtitles, helper captions (Apple secondaryLabel)
  static const Color textSecondary = Color(0xFF6C6C70);
  /// Tertiary captions, placeholder text, hints
  static const Color textTertiary = Color(0xFF9CA3AF);
  /// Inverted text for dark buttons & camera viewfinder badges
  static const Color textInverse = Color(0xFFFFFFFF);

  // --- Borders & Dividers ---
  /// Hairline list separator (0.5 pt on iOS)
  static const Color separator = Color(0xFFE5E7EB);
  /// Border stroke for cards & chips
  static const Color border = Color(0xFFE2E8F0);
  /// Subtle divider for light surfaces
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // --- Traffic-Light Verdict Semantic Tokens ---
  /// SAFE (Green) - Accessible Apple systemGreen for clear daylight legibility
  static const Color verdictSafe = Color(0xFF248A3D);
  /// SAFE soft background tint
  static const Color verdictSafeBg = Color(0xFFE8F8ED);
  /// SAFE border accent
  static const Color verdictSafeBorder = Color(0xFF86EFAC);

  /// CAUTION (Amber/Orange) - Accessible Apple systemOrange
  static const Color verdictCaution = Color(0xFFC96A00);
  /// CAUTION soft background tint
  static const Color verdictCautionBg = Color(0xFFFFF4E5);
  /// CAUTION border accent
  static const Color verdictCautionBorder = Color(0xFFFDE047);

  /// AVOID / DO NOT BUY (Red) - Accessible Apple systemRed
  static const Color verdictAvoid = Color(0xFFD70015);
  /// AVOID soft background tint
  static const Color verdictAvoidBg = Color(0xFFFFEBE9);
  /// AVOID border accent
  static const Color verdictAvoidBorder = Color(0xFFFCA5A5);

  // --- Species Intrinsic Risk Badges ---
  /// High Histamine badge text (Scombridae: Tongkol, Cakalang, Kembung, Tenggiri)
  static const Color riskHistamineText = Color(0xFFDC2626);
  /// High Histamine badge background
  static const Color riskHistamineBg = Color(0xFFFEF2F2);

  /// Ciguatera Watch badge text (Reef predators: Kerapu, Kakap)
  static const Color riskCiguateraText = Color(0xFFD97706);
  /// Ciguatera Watch badge background
  static const Color riskCiguateraBg = Color(0xFFFFFBEB);

  /// Low Intrinsic Risk badge text (Farmed / Freshwater: Bandeng, Gurame, Nila, Lele)
  static const Color riskLowText = Color(0xFF16A34A);
  /// Low Intrinsic Risk badge background
  static const Color riskLowBg = Color(0xFFF0FDF4);

  /// Unknown / Unverified species risk badge text
  static const Color riskUnknownText = Color(0xFF6B7280);
  /// Unknown species badge background
  static const Color riskUnknownBg = Color(0xFFF3F4F6);

  // --- Camera Viewfinder & Glass Material Tokens ---
  /// Frosted glass overlay backdrop (72% dark with blur)
  static const Color cameraGlass = Color(0xB81C1C1E);
  /// Translucent camera instruction pill surface
  static const Color cameraPillBg = Color(0xCC2C2C2E);
  /// Camera viewfinder AR corner guide
  static const Color cameraArGuide = Color(0xFF00C7BE);
  /// Camera shutter active ring
  static const Color cameraShutterRing = Color(0xFFFFFFFF);

  // --- Dark Mode Palette Equivalents ---
  static const Color darkCanvas = Color(0xFF000000);
  static const Color darkGroupedBackground = Color(0xFF1C1C1E);
  static const Color darkCard = Color(0xFF2C2C2E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkSeparator = Color(0xFF38383A);
  static const Color darkBorder = Color(0xFF3A3A3C);
}
