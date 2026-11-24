import 'package:material_ui/material_ui.dart';

/// Corner radius tokens and Apple Squircle shape generators.
abstract final class AppRadius {
  // --- Primitive Radii ---
  /// 6 pt - Micro badges, tiny tags
  static const double xs = 6.0;

  /// 8 pt - Small icons, chips
  static const double s = 8.0;

  /// 12 pt - Standard buttons, sensory option pills (v3.0 design system)
  static const double button = 12.0;

  /// 16 pt - Grouped cards, verdict hero containers, dialogs
  static const double card = 20.0;

  /// 20 pt - Modal page sheets (top corners)
  static const double sheet = 20.0;

  /// 28 pt - Large hero containers
  static const double hero = 28.0;

  /// Full capsule pill radius
  static const double full = 999.0;

  // --- BorderRadius Shortcuts ---
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderS = BorderRadius.all(Radius.circular(s));
  static const BorderRadius borderButton = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius borderCard = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius borderSheet = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius borderFull = BorderRadius.all(
    Radius.circular(full),
  );

  // --- Apple Squircle Shape Helpers (ContinuousRectangleBorder) ---
  /// Creates an Apple-style continuous curvature squircle border.
  static OutlinedBorder squircle(
    double radius, {
    BorderSide side = BorderSide.none,
  }) {
    return ContinuousRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius * 2.2)),
      side: side,
    );
  }

  /// Primary button shape: 12 pt squircle
  static OutlinedBorder buttonShape({BorderSide side = BorderSide.none}) =>
      squircle(button, side: side);

  /// Grouped card shape: 16 pt squircle
  static OutlinedBorder cardShape({BorderSide side = BorderSide.none}) =>
      squircle(card, side: side);

  /// Modal sheet top shape: 20 pt rounded top corners
  static const OutlinedBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(sheet)),
  );

  /// Capsule / Stadium shape
  static const OutlinedBorder capsuleShape = StadiumBorder();
}
