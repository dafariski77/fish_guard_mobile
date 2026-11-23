import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// Motion, animation timing, and haptic feedback design tokens (v3.0 Motion Edition).
/// Fluid and cozy spring physics with automatic Reduce Motion accessibility support.
abstract final class AppMotion {
  // --- Duration Tokens ---
  /// 120 ms - Button press squish, chip tap response
  static const Duration tap = Duration(milliseconds: 120);

  /// 220 ms - Icon toggles, chip color changes, pill toasts
  static const Duration micro = Duration(milliseconds: 220);

  /// 320 ms - Modal sheets, verdict card entrance, AR lock-on
  static const Duration spring = Duration(milliseconds: 320);

  /// 400 ms - Full-screen page transitions
  static const Duration page = Duration(milliseconds: 400);

  /// 1800 ms (Loop) - Gentle breathing guide pulse & scanning shimmer
  static const Duration breathe = Duration(milliseconds: 1800);

  /// 150 ms - Fallback crossfade when Reduce Motion is enabled
  static const Duration reduceMotionFallback = Duration(milliseconds: 150);

  // --- Animation Curves & Physics ---
  /// Quick responsive deceleration for tap feedback
  static const Curve curveTap = Curves.easeOutQuad;

  /// Soft organic ease-out for micro-interactions
  static const Curve curveMicro = Curves.easeOutCubic;

  /// Apple-style spring physics: mass 1.0, stiffness 320.0, damping 24.0
  static const SpringDescription springPhysics = SpringDescription(
    mass: 1.0,
    stiffness: 320.0,
    damping: 24.0,
  );

  /// Smooth sine curve for looping AR guide breathing
  static const Curve curveBreathe = Curves.easeInOutSine;

  // --- Transform Scales ---
  /// Button pressed scale factor (0.96)
  static const double buttonPressScale = 0.96;

  /// Sensory chip pop scale factor (1.04)
  static const double chipPopScale = 1.04;

  // --- Accessibility Check ---
  /// Returns whether motion animations should be disabled/simplified.
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  /// Returns effective duration respecting user's accessibility settings.
  static Duration duration(BuildContext context, Duration standard) {
    return shouldReduceMotion(context) ? reduceMotionFallback : standard;
  }

  // --- Paired Tactile Haptic Signatures ---
  /// Soft light impact for standard button presses
  static void tapHaptic() {
    HapticFeedback.lightImpact();
  }

  /// Subtle click for sensory chip selection
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  /// Medium reassuring impact when AI locks onto eye/gill
  static void lockOnHaptic() {
    HapticFeedback.mediumImpact();
  }

  /// Firm alert vibration for RED (Do Not Buy) verdict
  static void alertHaptic() {
    HapticFeedback.heavyImpact();
  }

  /// Cheerful double-tap for GREEN (Safe) verdict
  static void safeVerdictHaptic() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 70));
    HapticFeedback.lightImpact();
  }
}
