import 'package:flutter_test/flutter_test.dart';
import 'package:fish_guard_mobile/core/ml/inference_service.dart';
import 'package:fish_guard_mobile/core/ml/calibrated_market_driver.dart';
import 'package:fish_guard_mobile/core/ml/fish_inference_driver.dart';
import 'package:fish_guard_mobile/core/ml/hybrid_risk_engine.dart';
import 'package:fish_guard_mobile/core/models/species_prediction.dart';
import 'package:fish_guard_mobile/core/models/vision_freshness.dart';
import 'package:fish_guard_mobile/core/models/sensory_input.dart';

void main() {
  late InferenceService service;

  setUp(() {
    service = InferenceService(
      driver: CalibratedMarketDriver(),
      riskEngine: const HybridRiskEngine(),
    );
  });

  group('InferenceService End-to-End Execution Tests', () {
    test('Processes fresh iced Tongkol capture and produces GREEN verdict', () async {
      final input = ScanInput(
        sampleScenario: 'fresh_iced',
        sensory: const SensoryInput(
          smell: 'fresh_sea',
          texture: 'bounces_back',
          storage: 'packed_in_ice',
        ),
      );

      final result = await service.processScan(input);

      expect(result.scanId, isNotEmpty);
      expect(result.species.label, 'tongkol');
      expect(result.species.displayName, 'Tongkol (Bullet Tuna)');
      expect(result.species.confidence, greaterThanOrEqualTo(0.70));
      expect(result.vision.combinedFreshnessScore, greaterThanOrEqualTo(75.0));
      expect(result.vision.grade, 'SAFE');
      expect(result.verdict.status, 'GREEN');
      expect(result.verdict.isSafe, isTrue);
      expect(result.verdict.reasons, isNotEmpty);
    });

    test('Processes spoiled off-ice Tongkol capture and produces RED/YELLOW verdict', () async {
      final input = ScanInput(
        sampleScenario: 'spoiled_no_ice',
        sensory: const SensoryInput(
          smell: 'sour_ammonia',
          texture: 'mushy',
          storage: 'no_ice_room_temp',
        ),
      );

      final result = await service.processScan(input);

      expect(result.species.label, 'tongkol');
      expect(result.verdict.status, 'RED');
      expect(result.verdict.isAvoid, isTrue);
      expect(result.verdict.reasons, anyElement(contains('ammonia')));
    });

    test('Processes formalin-flagged Kembung and produces forced RED verdict', () async {
      final input = ScanInput(
        sampleScenario: 'formalin_flag',
        sensory: const SensoryInput(
          smell: 'odorless',
          texture: 'unnaturally_stiff',
          storage: 'packed_in_ice',
        ),
      );

      final result = await service.processScan(input);

      expect(result.species.label, 'kembung');
      expect(result.verdict.status, 'RED');
      expect(result.verdict.reasons.first, contains('formalin adulteration'));
    });

    test('Normalizes species to unknown when classifier confidence < 0.70', () async {
      final lowConfService = InferenceService(
        driver: _LowConfidenceDriver(),
        riskEngine: const HybridRiskEngine(),
      );

      final input = ScanInput(
        sampleScenario: 'fresh_iced',
        sensory: const SensoryInput(
          smell: 'fresh_sea',
          texture: 'bounces_back',
          storage: 'packed_in_ice',
        ),
      );

      final result = await lowConfService.processScan(input);

      expect(result.species.label, 'unknown');
      expect(result.species.displayName, 'Unknown Species');
      expect(result.species.confidence, 0.62);
      expect(result.species.intrinsicRisk, 'UNKNOWN_RISK');
      expect(result.species.isUnknownRisk, isTrue);
      // Advisory reason must be present
      expect(
        result.verdict.reasons,
        anyElement(contains('Species unverified (confidence < 70%)')),
      );
    });
  });
}

class _LowConfidenceDriver implements FishInferenceDriver {
  @override
  Future<SpeciesPrediction> detectSpecies({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  }) async {
    return const SpeciesPrediction(
      label: 'tongkol',
      displayName: 'Tongkol',
      confidence: 0.62,
      intrinsicRisk: 'HIGH_HISTAMINE',
    );
  }

  @override
  Future<VisionFreshness> evaluateVision({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  }) async {
    return const VisionFreshness(
      eyeBbox: [0.1, 0.1, 0.2, 0.2],
      gillBbox: [0.3, 0.3, 0.2, 0.2],
      eyeScore: 0.90,
      gillScore: 0.90,
      combinedFreshnessScore: 90.0,
      grade: 'SAFE',
    );
  }
}
