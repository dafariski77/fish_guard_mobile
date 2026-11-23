import '../models/species_prediction.dart';
import '../models/vision_freshness.dart';
import '../models/sensory_input.dart';
import '../models/final_verdict.dart';

/// Pure Dart implementation of Stage 3: Deterministic Hybrid Risk Scoring Engine.
/// Fuses computer vision freshness, species risk taxonomy, and sensory checks
/// to produce legally sound, explainable GREEN / YELLOW / RED safety verdicts.
class HybridRiskEngine {
  final double eyeWeight;
  final double gillWeight;
  final double safeThreshold;
  final double cautionThreshold;

  const HybridRiskEngine({
    this.eyeWeight = 0.45,
    this.gillWeight = 0.55,
    this.safeThreshold = 75.0,
    this.cautionThreshold = 50.0,
  });

  /// Computes weighted freshness score and vision grade.
  /// Formula: (0.45 * eye_score + 0.55 * gill_score) * 100
  VisionFreshness computeVisionFreshness({
    required double eyeScore,
    required double gillScore,
    List<double> eyeBbox = const [0.0, 0.0, 0.0, 0.0],
    List<double> gillBbox = const [0.0, 0.0, 0.0, 0.0],
  }) {
    final clampedEye = eyeScore.clamp(0.0, 1.0);
    final clampedGill = gillScore.clamp(0.0, 1.0);

    final rawScore = (eyeWeight * clampedEye + gillWeight * clampedGill) * 100.0;
    // Round to 1 decimal place
    final combined = (rawScore * 10).round() / 10.0;

    final String grade;
    if (combined >= safeThreshold) {
      grade = 'SAFE';
    } else if (combined >= cautionThreshold) {
      grade = 'CAUTION';
    } else {
      grade = 'AVOID';
    }

    return VisionFreshness(
      eyeBbox: eyeBbox,
      gillBbox: gillBbox,
      eyeScore: (clampedEye * 100).round() / 100.0,
      gillScore: (clampedGill * 100).round() / 100.0,
      combinedFreshnessScore: combined,
      grade: grade,
    );
  }

  /// Evaluates species prediction, vision freshness, and sensory input to output final verdict.
  FinalVerdict evaluateVerdict({
    required SpeciesPrediction species,
    required VisionFreshness vision,
    required SensoryInput sensory,
  }) {
    final displayName = species.displayName;
    final isHighHistamine = species.isHighHistamine;
    final combinedScore = vision.combinedFreshnessScore;
    final eyeScore = vision.eyeScore;
    final gillScore = vision.gillScore;

    final smell = sensory.smell;
    final texture = sensory.texture;
    final storage = sensory.storage;
    final isSkipped = sensory.skipped;

    // Priority 1: Check Illegal Chemical Adulteration (Formalin Flag)
    if (!isSkipped && smell == 'odorless' && texture == 'unnaturally_stiff') {
      return const FinalVerdict(
        status: 'RED',
        reasons: [
          'Suspected formalin adulteration: unnaturally stiff flesh paired with lack of natural fish scent.',
          'Chemical preservatives mask visual decay but do not make fish safe.',
        ],
        recommendation:
            'Do not purchase or consume. Report suspected chemical adulteration.',
      );
    }

    // Priority 2: Critical Spoilage Signs in Sensory Check
    if (!isSkipped && smell == 'sour_ammonia') {
      return const FinalVerdict(
        status: 'RED',
        reasons: [
          'Strong sour or ammonia odor indicates advanced microbial decomposition.',
        ],
        recommendation:
            'Do not buy. High risk of acute bacterial food poisoning.',
      );
    }

    if (!isSkipped && texture == 'mushy') {
      return const FinalVerdict(
        status: 'RED',
        reasons: [
          'Mushy flesh: severe muscle proteolysis and bacterial degradation.',
        ],
        recommendation:
            'Do not buy. Fish tissue is broken down and unsafe.',
      );
    }

    // Priority 3: Histamine Temperature Abuse Rules
    if (isHighHistamine && !isSkipped && storage == 'no_ice_room_temp') {
      if (combinedScore >= 70.0) {
        final reasons = <String>[
          '$displayName is a high-histamine species.',
          'Kept without ice: bacteria rapidly produce heat-stable histamine.',
        ];
        if (gillScore < 0.75) {
          reasons.add('Gills show early color dulling.');
        }
        return FinalVerdict(
          status: 'YELLOW',
          reasons: reasons,
          recommendation:
              'Cook immediately if purchased, or choose a fish packed in ice.',
        );
      } else {
        return FinalVerdict(
          status: 'RED',
          reasons: [
            '$displayName is a high-histamine species stored without ice.',
            'Visual freshness is degraded; high probability of toxic histamine build-up.',
            'Cooking or frying does NOT destroy histamine.',
            'Scombroid poisoning risk requires strict prevention.',
          ],
          recommendation:
              'Do not buy. Scombroid poisoning risk requires strict prevention.',
        );
      }
    }

    // Priority 4: Vision Freshness Score Thresholds
    final reasons = <String>[];
    String status = 'GREEN';
    String recommendation = '';

    if (combinedScore >= safeThreshold) {
      status = 'GREEN';
      reasons.add('Clear cornea and healthy eye convexity.');
      reasons.add('Gills show vibrant, natural reddish biological coloration.');
      recommendation =
          'Safe to buy. Keep chilled on ice, refrigerate within 2 hours, and cook within 24 hours.';

      if (species.isCiguateraWatch) {
        reasons.add(
            '$displayName is a reef predator. For maximum safety, avoid consuming head or viscera.');
      }
    } else if (combinedScore >= cautionThreshold) {
      status = 'YELLOW';
      if (eyeScore < 0.65) {
        reasons.add('Eye exhibits noticeable cloudiness or sunken pupil.');
      }
      if (gillScore < 0.65) {
        reasons.add('Gills show early brownish discoloration or fading.');
      }
      if (reasons.isEmpty) {
        reasons.add('Moderate biological freshness decline detected.');
      }
      recommendation =
          'Exercise caution. Check gills closely and cook thoroughly today if purchased.';
    } else {
      status = 'RED';
      reasons.add('Sunken or opaque eye indicates advanced post-mortem decay.');
      reasons.add('Gills show severe discoloration or graying.');
      recommendation = 'Do not purchase or consume. Fish is spoiled.';
    }

    // Add sensory skipped disclaimer if user bypassed questions
    if (isSkipped && status == 'GREEN') {
      reasons.add(
          'Sensory check skipped: invisible room-temperature or chemical hazards could not be assessed.');
    }

    return FinalVerdict(
      status: status,
      reasons: reasons,
      recommendation: recommendation,
    );
  }
}
