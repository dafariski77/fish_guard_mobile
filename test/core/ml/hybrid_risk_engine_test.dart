import 'package:flutter_test/flutter_test.dart';
import 'package:fish_guard_mobile/core/ml/hybrid_risk_engine.dart';
import 'package:fish_guard_mobile/core/models/species_prediction.dart';
import 'package:fish_guard_mobile/core/models/vision_freshness.dart';
import 'package:fish_guard_mobile/core/models/sensory_input.dart';

void main() {
  late HybridRiskEngine engine;

  setUp(() {
    engine = HybridRiskEngine();
  });

  group('HybridRiskEngine Vision Freshness Calculations', () {
    test('Calculates weighted freshness score (eye: 0.45, gill: 0.55)', () {
      final vision = engine.computeVisionFreshness(
        eyeScore: 0.80,
        gillScore: 0.90,
        eyeBbox: [0.1, 0.2, 0.3, 0.4],
        gillBbox: [0.5, 0.6, 0.7, 0.8],
      );

      // (0.45 * 0.80 + 0.55 * 0.90) * 100 = (0.36 + 0.495) * 100 = 85.5
      expect(vision.combinedFreshnessScore, 85.5);
      expect(vision.grade, 'SAFE');
      expect(vision.isSafe, isTrue);
      expect(vision.eyeBbox, [0.1, 0.2, 0.3, 0.4]);
      expect(vision.gillBbox, [0.5, 0.6, 0.7, 0.8]);
    });

    test('Clamps scores between 0 and 1', () {
      final vision = engine.computeVisionFreshness(
        eyeScore: 1.5,
        gillScore: -0.5,
      );
      // (0.45 * 1.0 + 0.55 * 0.0) * 100 = 45.0
      expect(vision.combinedFreshnessScore, 45.0);
      expect(vision.grade, 'AVOID');
    });
  });

  group('HybridRiskEngine Priority Rules & Legal/Medical Safety Verdicts', () {
    const freshVision = VisionFreshness(
      eyeBbox: [0.1, 0.1, 0.2, 0.2],
      gillBbox: [0.3, 0.3, 0.2, 0.2],
      eyeScore: 0.9,
      gillScore: 0.9,
      combinedFreshnessScore: 90.0,
      grade: 'SAFE',
    );

    const tongkolSpecies = SpeciesPrediction(
      label: 'tongkol',
      displayName: 'Tongkol (Bullet Tuna)',
      confidence: 0.85,
      intrinsicRisk: 'HIGH_HISTAMINE',
    );

    test('Priority 1: Formalin Adulteration Flag forces RED even with 90% vision', () {
      const formalinSensory = SensoryInput(
        smell: 'odorless',
        texture: 'unnaturally_stiff',
        storage: 'packed_in_ice',
      );

      final verdict = engine.evaluateVerdict(
        species: tongkolSpecies,
        vision: freshVision,
        sensory: formalinSensory,
      );

      expect(verdict.status, 'RED');
      expect(verdict.isAvoid, isTrue);
      expect(verdict.reasons.first, contains('formalin adulteration'));
      expect(verdict.recommendation, contains('Do not purchase'));
    });

    test('Priority 2: Severe Spoilage (Sour/Ammonia Smell) forces RED', () {
      const spoiledSmellSensory = SensoryInput(
        smell: 'sour_ammonia',
        texture: 'bounces_back',
        storage: 'packed_in_ice',
      );

      final verdict = engine.evaluateVerdict(
        species: tongkolSpecies,
        vision: freshVision,
        sensory: spoiledSmellSensory,
      );

      expect(verdict.status, 'RED');
      expect(verdict.reasons.first, contains('ammonia odor'));
    });

    test('Priority 2: Severe Spoilage (Mushy Flesh) forces RED', () {
      const mushySensory = SensoryInput(
        smell: 'fresh_sea',
        texture: 'mushy',
        storage: 'packed_in_ice',
      );

      final verdict = engine.evaluateVerdict(
        species: tongkolSpecies,
        vision: freshVision,
        sensory: mushySensory,
      );

      expect(verdict.status, 'RED');
      expect(verdict.reasons.first, contains('Mushy flesh'));
    });

    test('Priority 3: Histamine Off-Ice with good vision (>= 70) yields YELLOW warning', () {
      const offIceSensory = SensoryInput(
        smell: 'fresh_sea',
        texture: 'bounces_back',
        storage: 'no_ice_room_temp',
      );

      final verdict = engine.evaluateVerdict(
        species: tongkolSpecies,
        vision: freshVision,
        sensory: offIceSensory,
      );

      expect(verdict.status, 'YELLOW');
      expect(verdict.isCaution, isTrue);
      expect(verdict.reasons.first, contains('high-histamine'));
      expect(verdict.recommendation, contains('Cook immediately'));
    });

    test('Priority 3: Histamine Off-Ice with degraded vision (< 70) forces RED', () {
      const degradedVision = VisionFreshness(
        eyeBbox: [0.1, 0.1, 0.2, 0.2],
        gillBbox: [0.3, 0.3, 0.2, 0.2],
        eyeScore: 0.65,
        gillScore: 0.65,
        combinedFreshnessScore: 65.0,
        grade: 'CAUTION',
      );

      const offIceSensory = SensoryInput(
        smell: 'fresh_sea',
        texture: 'bounces_back',
        storage: 'no_ice_room_temp',
      );

      final verdict = engine.evaluateVerdict(
        species: tongkolSpecies,
        vision: degradedVision,
        sensory: offIceSensory,
      );

      expect(verdict.status, 'RED');
      expect(verdict.reasons, anyElement(contains('Scombroid poisoning')));
    });

    test('Priority 4: Fresh fish on ice yields GREEN Safe to Buy', () {
      const safeSensory = SensoryInput(
        smell: 'fresh_sea',
        texture: 'bounces_back',
        storage: 'packed_in_ice',
      );

      final verdict = engine.evaluateVerdict(
        species: tongkolSpecies,
        vision: freshVision,
        sensory: safeSensory,
      );

      expect(verdict.status, 'GREEN');
      expect(verdict.isSafe, isTrue);
      expect(verdict.recommendation, contains('Safe to buy'));
    });

    test('Priority 4: Skipped sensory check appends disclaimer to GREEN verdict', () {
      final skippedSensory = SensoryInput.skipped();

      final verdict = engine.evaluateVerdict(
        species: tongkolSpecies,
        vision: freshVision,
        sensory: skippedSensory,
      );

      expect(verdict.status, 'GREEN');
      expect(verdict.reasons.last, contains('Sensory check skipped'));
    });

    test('Unverified species (UNKNOWN_RISK) appends warning advisory reason', () {
      const unknownSpecies = SpeciesPrediction(
        label: 'unknown',
        displayName: 'Unknown Species',
        confidence: 0.55,
        intrinsicRisk: 'UNKNOWN_RISK',
      );

      const safeSensory = SensoryInput(
        smell: 'fresh_sea',
        texture: 'bounces_back',
        storage: 'packed_in_ice',
      );

      final verdict = engine.evaluateVerdict(
        species: unknownSpecies,
        vision: freshVision,
        sensory: safeSensory,
      );

      expect(verdict.status, 'GREEN');
      expect(
        verdict.reasons,
        anyElement(contains('Species unverified (confidence < 70%)')),
      );
    });
  });
}
