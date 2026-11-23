import 'package:material_ui/material_ui.dart';

/// Immutable model representing an individual onboarding slide.
class OnboardingItem {
  final String title;
  final String description;
  final Widget illustration;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.illustration,
  });
}
