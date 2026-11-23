/// Domain model representing species prediction from Stage 2 classifier.
class SpeciesPrediction {
  final String label;
  final String displayName;
  final double confidence;
  final String intrinsicRisk;

  const SpeciesPrediction({
    required this.label,
    required this.displayName,
    required this.confidence,
    required this.intrinsicRisk,
  });

  bool get isHighHistamine => intrinsicRisk == 'HIGH_HISTAMINE';
  bool get isCiguateraWatch => intrinsicRisk == 'CIGUATERA_WATCH';
  bool get isUnknownRisk => intrinsicRisk == 'UNKNOWN_RISK';

  factory SpeciesPrediction.fromJson(Map<String, dynamic> json) {
    return SpeciesPrediction(
      label: json['label'] as String? ?? 'unknown',
      displayName: json['display_name'] as String? ?? 'Unknown Fish',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      intrinsicRisk: json['intrinsic_risk'] as String? ?? 'UNKNOWN_RISK',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'display_name': displayName,
    'confidence': confidence,
    'intrinsic_risk': intrinsicRisk,
  };
}
