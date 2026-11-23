/// Domain model representing the hybrid risk fusion engine's final safety determination.
class FinalVerdict {
  final String status; // GREEN, YELLOW, RED
  final List<String> reasons;
  final String recommendation;

  const FinalVerdict({
    required this.status,
    required this.reasons,
    required this.recommendation,
  });

  bool get isSafe => status == 'GREEN';
  bool get isCaution => status == 'YELLOW';
  bool get isAvoid => status == 'RED';

  factory FinalVerdict.fromJson(Map<String, dynamic> json) {
    return FinalVerdict(
      status: json['status'] as String? ?? 'RED',
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      recommendation: json['recommendation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'reasons': reasons,
    'recommendation': recommendation,
  };
}
