import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_guard_mobile/core/models/scan_result_model.dart';
import 'package:fish_guard_mobile/core/routing/route_arguments.dart';

void main() {
  group('PRD Section 5 ScanResultModel Contract Tests', () {
    const rawJson = '''
    {
      "scan_id": "550e8400-e29b-41d4-a716-446655440000",
      "timestamp": "2026-11-22T04:51:55+07:00",
      "species_prediction": {
        "label": "tongkol",
        "display_name": "Tongkol (Bullet Tuna)",
        "confidence": 0.74,
        "intrinsic_risk": "HIGH_HISTAMINE"
      },
      "vision_freshness": {
        "eye_bbox": [0.42, 0.31, 0.12, 0.12],
        "gill_bbox": [0.55, 0.40, 0.18, 0.22],
        "eye_score": 0.77,
        "gill_score": 0.77,
        "combined_freshness_score": 77.0,
        "grade": "SAFE"
      },
      "sensory_input": {
        "smell": "fresh_sea",
        "texture": "bounces_back",
        "storage": "packed_in_ice",
        "skipped": false
      },
      "final_verdict": {
        "status": "GREEN",
        "reasons": [
          "Clear cornea and healthy eye convexity.",
          "Gills show vibrant, natural reddish biological coloration."
        ],
        "recommendation": "Safe to buy. Keep chilled on ice, refrigerate within 2 hours, and cook within 24 hours."
      }
    }
    ''';

    test('Parses Section 5 JSON correctly into domain model', () {
      final Map<String, dynamic> data = jsonDecode(rawJson);
      final model = ScanResultModel.fromJson(data);

      expect(model.scanId, '550e8400-e29b-41d4-a716-446655440000');
      expect(model.species.label, 'tongkol');
      expect(model.species.displayName, 'Tongkol (Bullet Tuna)');
      expect(model.species.confidence, 0.74);
      expect(model.species.intrinsicRisk, 'HIGH_HISTAMINE');

      expect(model.vision.eyeBbox, [0.42, 0.31, 0.12, 0.12]);
      expect(model.vision.gillBbox, [0.55, 0.40, 0.18, 0.22]);
      expect(model.vision.eyeScore, 0.77);
      expect(model.vision.gillScore, 0.77);
      expect(model.vision.combinedFreshnessScore, 77.0);
      expect(model.vision.grade, 'SAFE');

      expect(model.sensory.smell, 'fresh_sea');
      expect(model.sensory.texture, 'bounces_back');
      expect(model.sensory.storage, 'packed_in_ice');
      expect(model.sensory.skipped, false);

      expect(model.verdict.status, 'GREEN');
      expect(model.verdict.isSafe, true);
      expect(model.verdict.isCaution, false);
      expect(model.verdict.isAvoid, false);
      expect(model.verdict.reasons.length, 2);
      expect(model.verdict.recommendation, contains('Safe to buy'));
    });

    test('Round-trips to JSON and preserves all fields', () {
      final Map<String, dynamic> data = jsonDecode(rawJson);
      final model = ScanResultModel.fromJson(data);
      final encoded = model.toJson();

      expect(encoded['scan_id'], model.scanId);
      expect(encoded['species_prediction']['label'], 'tongkol');
      expect(encoded['vision_freshness']['combined_freshness_score'], 77.0);
      expect(encoded['final_verdict']['status'], 'GREEN');
    });

    test('Converts seamlessly to VerdictRouteArgs', () {
      final Map<String, dynamic> data = jsonDecode(rawJson);
      final model = ScanResultModel.fromJson(data);
      final args = VerdictRouteArgs.fromScanResult(model);

      expect(args.speciesName, 'Tongkol (Bullet Tuna)');
      expect(args.score, 77);
      expect(args.isCaution, false);
      expect(args.isAvoid, false);
      expect(args.scanResult, model);
    });
  });
}
