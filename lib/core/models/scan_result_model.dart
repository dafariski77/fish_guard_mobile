import 'species_prediction.dart';
import 'vision_freshness.dart';
import 'sensory_input.dart';
import 'final_verdict.dart';

/// Top-level Cross-Team Contract model defined in PRD.md Section 5.
class ScanResultModel {
  final String scanId;
  final DateTime timestamp;
  final SpeciesPrediction species;
  final VisionFreshness vision;
  final SensoryInput sensory;
  final FinalVerdict verdict;
  final String? imagePath;

  const ScanResultModel({
    required this.scanId,
    required this.timestamp,
    required this.species,
    required this.vision,
    required this.sensory,
    required this.verdict,
    this.imagePath,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      scanId: json['scan_id'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      species: SpeciesPrediction.fromJson(
        json['species_prediction'] as Map<String, dynamic>? ?? {},
      ),
      vision: VisionFreshness.fromJson(
        json['vision_freshness'] as Map<String, dynamic>? ?? {},
      ),
      sensory: SensoryInput.fromJson(
        json['sensory_input'] as Map<String, dynamic>? ?? {},
      ),
      verdict: FinalVerdict.fromJson(
        json['final_verdict'] as Map<String, dynamic>? ?? {},
      ),
      imagePath: json['image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'scan_id': scanId,
    'timestamp': timestamp.toIso8601String(),
    'species_prediction': species.toJson(),
    'vision_freshness': vision.toJson(),
    'sensory_input': sensory.toJson(),
    'final_verdict': verdict.toJson(),
    if (imagePath != null) 'image_path': imagePath,
  };
}
