import 'package:material_ui/material_ui.dart';

/// Elevation and diffused ambient shadow tokens following modern Apple HIG aesthetics.
abstract final class AppShadows {
  /// Subtle ambient elevation for interactive cards & list rows
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x08000000), // 3% black
      blurRadius: 8.0,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Standard card elevation
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 16.0,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Floating CTAs, bottom action bars, active toasts
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 24.0,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Modal bottom sheet backdrop shadow
  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 32.0,
      offset: Offset(0, -4),
      spreadRadius: 0,
    ),
  ];

  /// Soft glowing aura for SAFE verdict
  static const List<BoxShadow> verdictSafeGlow = [
    BoxShadow(
      color: Color(0x26248A3D), // 15% Safe Green
      blurRadius: 20.0,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  /// Soft glowing aura for CAUTION verdict
  static const List<BoxShadow> verdictCautionGlow = [
    BoxShadow(
      color: Color(0x26C96A00), // 15% Caution Amber
      blurRadius: 20.0,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  /// Soft glowing aura for AVOID verdict
  static const List<BoxShadow> verdictAvoidGlow = [
    BoxShadow(
      color: Color(0x26D70015), // 15% Avoid Red
      blurRadius: 20.0,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}
