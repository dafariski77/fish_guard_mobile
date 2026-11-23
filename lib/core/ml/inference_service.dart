import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/scan_result_model.dart';
import '../models/species_prediction.dart';
import '../models/vision_freshness.dart';
import '../models/sensory_input.dart';
import 'fish_inference_driver.dart';
import 'calibrated_market_driver.dart';
import 'tflite_inference_driver.dart';
import 'hybrid_risk_engine.dart';

/// Input parameters for an inspection run.
class ScanInput {
  final String? wholeFishImagePath;
  final String? eyeGillImagePath;
  final SensoryInput sensory;
  final String sampleScenario;

  const ScanInput({
    this.wholeFishImagePath,
    this.eyeGillImagePath,
    required this.sensory,
    this.sampleScenario = 'fresh_iced',
  });
}

/// Central coordinator for edge machine learning and hybrid safety verdicts.
class InferenceService {
  final FishInferenceDriver driver;
  final HybridRiskEngine riskEngine;
  static const _uuid = Uuid();

  const InferenceService({
    required this.driver,
    this.riskEngine = const HybridRiskEngine(),
  });

  /// Phase 1: Fast species detection and vision freshness check
  Future<({SpeciesPrediction species, VisionFreshness vision})>
      detectSpeciesAndVision(ScanInput input) async {
    final species = await driver.detectSpecies(
      wholeFishPath: input.wholeFishImagePath,
      eyeGillPath: input.eyeGillImagePath,
      scenario: input.sampleScenario,
    );

    final vision = await driver.evaluateVision(
      wholeFishPath: input.wholeFishImagePath,
      eyeGillPath: input.eyeGillImagePath,
      scenario: input.sampleScenario,
    );

    return (species: species, vision: vision);
  }

  /// Phase 2: Full pipeline execution producing PRD Section 5 ScanResultModel
  Future<ScanResultModel> processScan(ScanInput input) async {
    final detection = await detectSpeciesAndVision(input);

    final verdict = riskEngine.evaluateVerdict(
      species: detection.species,
      vision: detection.vision,
      sensory: input.sensory,
    );

    return ScanResultModel(
      scanId: _uuid.v4(),
      timestamp: DateTime.now(),
      species: detection.species,
      vision: detection.vision,
      sensory: input.sensory,
      verdict: verdict,
    );
  }
}

/// Global provider for the InferenceService.
/// Defaults to [TfLiteInferenceDriver] with automatic test/benchmark fallback.
final fishInferenceServiceProvider = Provider<InferenceService>((ref) {
  return InferenceService(
    driver: TfLiteInferenceDriver(),
    riskEngine: const HybridRiskEngine(),
  );
});
