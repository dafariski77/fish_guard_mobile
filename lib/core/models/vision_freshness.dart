/// Domain model representing vision-derived biological freshness scores and bounding boxes.
class VisionFreshness {
  final List<double> eyeBbox;
  final List<double> gillBbox;
  final double eyeScore;
  final double gillScore;
  final double combinedFreshnessScore;
  final String grade;

  const VisionFreshness({
    required this.eyeBbox,
    required this.gillBbox,
    required this.eyeScore,
    required this.gillScore,
    required this.combinedFreshnessScore,
    required this.grade,
  });

  bool get isSafe => grade == 'SAFE';
  bool get isCaution => grade == 'CAUTION';
  bool get isAvoid => grade == 'AVOID';

  factory VisionFreshness.fromJson(Map<String, dynamic> json) {
    return VisionFreshness(
      eyeBbox: (json['eye_bbox'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [0.0, 0.0, 0.0, 0.0],
      gillBbox: (json['gill_bbox'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [0.0, 0.0, 0.0, 0.0],
      eyeScore: (json['eye_score'] as num?)?.toDouble() ?? 0.0,
      gillScore: (json['gill_score'] as num?)?.toDouble() ?? 0.0,
      combinedFreshnessScore:
          (json['combined_freshness_score'] as num?)?.toDouble() ?? 0.0,
      grade: json['grade'] as String? ?? 'AVOID',
    );
  }

  Map<String, dynamic> toJson() => {
    'eye_bbox': eyeBbox,
    'gill_bbox': gillBbox,
    'eye_score': eyeScore,
    'gill_score': gillScore,
    'combined_freshness_score': combinedFreshnessScore,
    'grade': grade,
  };
}
