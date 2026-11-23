import 'package:material_ui/material_ui.dart';

/// Spacing and touch-target design tokens based on the 4pt/8pt grid system.
/// Designed for wet-market thumb-zone ergonomics.
abstract final class AppSpacing {
  // --- Primitive Spacing Scale (4pt/8pt grid) ---
  /// 2 pt
  static const double xxs = 2.0;
  /// 4 pt
  static const double xs = 4.0;
  /// 8 pt
  static const double s = 8.0;
  /// 12 pt
  static const double m = 12.0;
  /// 16 pt - Standard screen horizontal margin & card padding
  static const double l = 16.0;
  /// 20 pt
  static const double xl = 20.0;
  /// 24 pt - Thumb zone bottom safe distance
  static const double xxl = 24.0;
  /// 32 pt - Section gap
  static const double xxxl = 32.0;
  /// 40 pt
  static const double huge = 40.0;
  /// 48 pt
  static const double massive = 48.0;

  // --- Wet-Market Touch Targets (strictly >= 44x44 pt per Apple HIG) ---
  /// Minimum accessible interactive target per Apple HIG (44x44 pt)
  static const double minTouchTarget = 44.0;
  /// Primary wet-market CTA button height (54 pt) in bottom 40% thumb zone
  static const double primaryButtonHeight = 54.0;
  /// Sensory check tap chip height (48 pt)
  static const double sensoryChipHeight = 48.0;
  /// Viewfinder tool buttons (Torch/Flash, Info, Settings)
  static const double viewfinderButtonSize = 48.0;
  /// Camera shutter button outer ring diameter (76 pt)
  static const double shutterOuterSize = 76.0;
  /// Camera shutter button inner core diameter (62 pt)
  static const double shutterInnerSize = 62.0;

  // --- Layout Paddings & Insets ---
  /// Standard screen content padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: l);
  /// Grouped card internal padding
  static const EdgeInsets cardPadding = EdgeInsets.all(l);
  /// Compact card padding
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(m);
  /// Inset list row padding
  static const EdgeInsets listRowPadding = EdgeInsets.symmetric(horizontal: l, vertical: m);
  /// Primary button internal padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: xl, vertical: 14.0);
  /// Sensory pill padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: m, vertical: s);
  /// Bottom thumb zone padding (above navigation / home bar)
  static const EdgeInsets bottomThumbZone = EdgeInsets.only(left: l, right: l, bottom: xxl, top: m);
}
