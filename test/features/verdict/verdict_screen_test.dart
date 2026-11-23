import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fish_guard_mobile/core/theme/theme.dart';
import 'package:fish_guard_mobile/core/models/scan_result_model.dart';
import 'package:fish_guard_mobile/core/models/species_prediction.dart';
import 'package:fish_guard_mobile/core/models/vision_freshness.dart';
import 'package:fish_guard_mobile/core/models/sensory_input.dart';
import 'package:fish_guard_mobile/core/models/final_verdict.dart';
import 'package:fish_guard_mobile/features/verdict/screens/verdict_screen.dart';

void main() {
  group('VerdictScreen Dynamic Contract Binding Tests', () {
    testWidgets('Renders dynamic model outputs: score gauge, risk badge, and itemized reasons',
        (WidgetTester tester) async {
      final scanResult = ScanResultModel(
        scanId: 'test-scan-uuid',
        timestamp: DateTime.now(),
        species: const SpeciesPrediction(
          label: 'tongkol',
          displayName: 'Tongkol (Bullet Tuna)',
          confidence: 0.88,
          intrinsicRisk: 'HIGH_HISTAMINE',
        ),
        vision: const VisionFreshness(
          eyeBbox: [0.42, 0.31, 0.12, 0.12],
          gillBbox: [0.55, 0.40, 0.18, 0.22],
          eyeScore: 0.86,
          gillScore: 0.89,
          combinedFreshnessScore: 87.7,
          grade: 'SAFE',
        ),
        sensory: const SensoryInput(
          smell: 'fresh_sea',
          texture: 'bounces_back',
          storage: 'packed_in_ice',
        ),
        verdict: const FinalVerdict(
          status: 'GREEN',
          reasons: [
            'Clear cornea and healthy eye convexity.',
            'Gills show vibrant, natural reddish biological coloration.',
          ],
          recommendation: 'Safe to buy. Keep chilled on ice, refrigerate within 2 hours.',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VerdictScreen(
            speciesName: scanResult.species.displayName,
            score: scanResult.vision.combinedFreshnessScore.round(),
            scanResult: scanResult,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Gauge & Header
      expect(find.text('88%'), findsOneWidget);
      expect(find.text('Safe to Buy'), findsOneWidget);

      // Species details
      expect(find.text('Tongkol (Bullet Tuna)'), findsOneWidget);
      expect(find.text('HIGH HISTAMINE'), findsOneWidget);
      expect(find.text('88% match'), findsOneWidget);

      // Explainability & Reasons
      expect(find.text('Clear cornea and healthy eye convexity.'), findsOneWidget);
      expect(find.text('Gills show vibrant, natural reddish biological coloration.'), findsOneWidget);
      expect(find.textContaining('Safe to buy. Keep chilled on ice'), findsOneWidget);

      // Bounding box overlay text
      expect(find.text('EYE 86%'), findsOneWidget);
      expect(find.text('GILL 89%'), findsOneWidget);
    });

    testWidgets('Renders LOW INTRINSIC RISK badge and unverified disclaimer for unknown species',
        (WidgetTester tester) async {
      final scanResult = ScanResultModel(
        scanId: 'low-risk-scan-uuid',
        timestamp: DateTime.now(),
        species: const SpeciesPrediction(
          label: 'bandeng',
          displayName: 'Bandeng (Milkfish)',
          confidence: 0.95,
          intrinsicRisk: 'LOW_INTRINSIC_RISK',
        ),
        vision: const VisionFreshness(
          eyeBbox: [0.30, 0.20, 0.15, 0.15],
          gillBbox: [0.50, 0.35, 0.20, 0.25],
          eyeScore: 0.92,
          gillScore: 0.95,
          combinedFreshnessScore: 93.7,
          grade: 'SAFE',
        ),
        sensory: const SensoryInput(
          smell: 'fresh_sea',
          texture: 'bounces_back',
          storage: 'packed_in_ice',
        ),
        verdict: const FinalVerdict(
          status: 'GREEN',
          reasons: [
            'Clear cornea and healthy eye convexity.',
            'Gills show vibrant, natural reddish biological coloration.',
          ],
          recommendation: 'Safe to buy. Keep chilled on ice.',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VerdictScreen(
            speciesName: scanResult.species.displayName,
            score: scanResult.vision.combinedFreshnessScore.round(),
            scanResult: scanResult,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bandeng (Milkfish)'), findsOneWidget);
      expect(find.text('LOW INTRINSIC RISK'), findsOneWidget);
      expect(find.text('EYE 92%'), findsOneWidget);
      expect(find.text('GILL 95%'), findsOneWidget);
    });
  });
}
