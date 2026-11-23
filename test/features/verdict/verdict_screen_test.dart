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
    });
  });
}
