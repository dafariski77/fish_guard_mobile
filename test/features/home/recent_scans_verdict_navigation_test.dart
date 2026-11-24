import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_guard_mobile/core/models/scan_result_model.dart';
import 'package:fish_guard_mobile/core/models/species_prediction.dart';
import 'package:fish_guard_mobile/core/models/vision_freshness.dart';
import 'package:fish_guard_mobile/core/models/sensory_input.dart';
import 'package:fish_guard_mobile/core/models/final_verdict.dart';
import 'package:fish_guard_mobile/features/home/repositories/recent_scans_repository.dart';
import 'package:fish_guard_mobile/features/home/viewmodels/recent_scans_viewmodel.dart';
import 'package:fish_guard_mobile/features/verdict/screens/verdict_screen.dart';
import 'package:fish_guard_mobile/main.dart';
import 'package:fish_guard_mobile/core/routing/routing.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Recent Scans Safety Navigation & Explainability Preservation Tests', () {
    testWidgets('Tapping an AVOID/RED scan in RecentScansCard preserves AVOID verdict and explainability',
        (WidgetTester tester) async {
      final spoiledResult = ScanResultModel(
        scanId: 'spoiled-scan-id',
        timestamp: DateTime.now(),
        species: const SpeciesPrediction(
          label: 'tongkol',
          displayName: 'Tongkol (Bullet Tuna)',
          confidence: 0.85,
          intrinsicRisk: 'HIGH_HISTAMINE',
        ),
        vision: const VisionFreshness(
          eyeBbox: [0.4, 0.3, 0.1, 0.1],
          gillBbox: [0.5, 0.4, 0.2, 0.2],
          eyeScore: 0.35,
          gillScore: 0.40,
          combinedFreshnessScore: 37.8,
          grade: 'AVOID',
        ),
        sensory: const SensoryInput(
          smell: 'sour_ammonia',
          texture: 'mushy',
          storage: 'no_ice_room_temp',
        ),
        verdict: const FinalVerdict(
          status: 'RED',
          reasons: [
            'Strong sour or ammonia odor indicates advanced microbial decomposition.',
            'Mushy flesh: severe muscle proteolysis and bacterial degradation.',
          ],
          recommendation: 'Do not buy. High risk of acute bacterial food poisoning.',
        ),
      );

      final router = AppRouter.createRouter(initialLocation: AppRoutes.home);

      await tester.pumpWidget(
        FishGuardApp(
          router: router,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Add the spoiled scan to the repository
      final element = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(element);
      final repo = container.read(recentScansRepositoryProvider);
      await repo.addScanResult(spoiledResult);

      // Trigger loadScans and advance fake async clock past the 10ms delay
      container.read(recentScansViewModelProvider.notifier).loadScans();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Tap the item in the list
      await tester.tap(find.text('Tongkol (Bullet Tuna)').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(VerdictScreen), findsOneWidget);
      // MUST NOT be Safe to Buy! Must preserve RED / Do Not Buy
      expect(find.text('Do Not Buy (High Risk)'), findsOneWidget);
      expect(find.text('Strong sour or ammonia odor indicates advanced microbial decomposition.'), findsOneWidget);
      expect(find.textContaining('Do not buy. High risk of acute bacterial'), findsOneWidget);
    });
  });
}
