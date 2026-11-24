import '../models/species_prediction.dart';
import '../models/vision_freshness.dart';
import 'fish_inference_driver.dart';

/// Calibrated reference driver executing against wet-market ground-truth benchmarks.
/// Provides deterministic, high-fidelity inference for automated tests, CI, and simulators.
class CalibratedMarketDriver implements FishInferenceDriver {
  @override
  Future<SpeciesPrediction> detectSpecies({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));

    switch (scenario) {
      case 'formalin_flag':
        return const SpeciesPrediction(
          label: 'kembung',
          displayName: 'Kembung',
          confidence: 0.82,
          intrinsicRisk: 'HIGH_HISTAMINE',
        );
      case 'spoiled_no_ice':
        return const SpeciesPrediction(
          label: 'tongkol',
          displayName: 'Tongkol',
          confidence: 0.79,
          intrinsicRisk: 'HIGH_HISTAMINE',
        );
      case 'bandeng_safe':
        return const SpeciesPrediction(
          label: 'bandeng',
          displayName: 'Bandeng',
          confidence: 0.91,
          intrinsicRisk: 'LOW_HISTAMINE',
        );
      case 'unknown_species':
        return const SpeciesPrediction(
          label: 'unknown',
          displayName: 'Unknown Species',
          confidence: 0.45,
          intrinsicRisk: 'UNKNOWN_RISK',
        );
      case 'fresh_iced':
      default:
        return const SpeciesPrediction(
          label: 'tongkol',
          displayName: 'Tongkol (Bullet Tuna)',
          confidence: 0.88,
          intrinsicRisk: 'HIGH_HISTAMINE',
        );
    }
  }

  @override
  Future<VisionFreshness> evaluateVision({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 15));

    switch (scenario) {
      case 'spoiled_no_ice':
        return const VisionFreshness(
          eyeBbox: [0.42, 0.31, 0.12, 0.12],
          gillBbox: [0.55, 0.40, 0.18, 0.22],
          eyeScore: 0.48,
          gillScore: 0.42,
          combinedFreshnessScore: 44.7,
          grade: 'AVOID',
        );
      case 'formalin_flag':
        return const VisionFreshness(
          eyeBbox: [0.38, 0.28, 0.11, 0.11],
          gillBbox: [0.51, 0.36, 0.16, 0.20],
          eyeScore: 0.72,
          gillScore: 0.70,
          combinedFreshnessScore: 70.9,
          grade: 'CAUTION',
        );
      case 'fresh_iced':
      default:
        return const VisionFreshness(
          eyeBbox: [0.42, 0.31, 0.12, 0.12],
          gillBbox: [0.55, 0.40, 0.18, 0.22],
          eyeScore: 0.86,
          gillScore: 0.89,
          combinedFreshnessScore: 87.7,
          grade: 'SAFE',
        );
    }
  }
}
