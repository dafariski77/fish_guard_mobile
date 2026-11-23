import 'package:material_ui/material_ui.dart';

/// Immutable model representing medical guidance for a fish poisoning category.
class PoisoningConditionModel {
  final String title;
  final String subtitle;
  final Color tagColor;
  final Color tagBg;
  final String tagName;
  final String onsetTime;
  final List<String> symptoms;
  final List<String> firstAidSteps;

  const PoisoningConditionModel({
    required this.title,
    required this.subtitle,
    required this.tagColor,
    required this.tagBg,
    required this.tagName,
    required this.onsetTime,
    required this.symptoms,
    required this.firstAidSteps,
  });
}
