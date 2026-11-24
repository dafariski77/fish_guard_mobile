import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fish_guard_mobile/core/theme/theme.dart';
import 'package:fish_guard_mobile/main.dart';
import 'package:fish_guard_mobile/core/routing/routing.dart';
import 'package:fish_guard_mobile/features/home/models/recent_scan_model.dart';
import 'package:fish_guard_mobile/features/home/repositories/recent_scans_repository.dart';
import 'package:fish_guard_mobile/features/home/viewmodels/recent_scans_viewmodel.dart';
import 'package:fish_guard_mobile/features/home/screens/home_screen.dart';
import 'package:fish_guard_mobile/features/scanner/screens/scanner_viewfinder_screen.dart';
import 'package:fish_guard_mobile/features/first_aid/screens/first_aid_screen.dart';
import 'package:fish_guard_mobile/features/verdict/screens/verdict_screen.dart';

void main() {
  group('FishGuard Complete Sliced UI Flow Tests', () {
    testWidgets('3-Step Onboarding full walkthrough', (WidgetTester tester) async {
      await tester.pumpWidget(const FishGuardApp());
      await tester.pumpAndSettle();

      // Step 1
      expect(find.text('Instant Wet-Market Safety'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2
      expect(find.text('Works 100% Offline'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 3
      expect(find.text('Detect Invisible Hazards'), findsOneWidget);
      expect(find.text('Enable Camera & Get Started'), findsOneWidget);

      await tester.tap(find.text('Enable Camera & Get Started'));
      await tester.pumpAndSettle();

      // Land on Home
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Home to Offline First-Aid Guide navigation', (WidgetTester tester) async {
      await tester.pumpWidget(FishGuardApp(
        router: AppRouter.createRouter(initialLocation: AppRoutes.home),
      ));
      await tester.pumpAndSettle();

      // Scroll down to First Aid Entry
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Offline Fish Poisoning Guide'));
      await tester.pumpAndSettle();

      expect(find.byType(FirstAidScreen), findsOneWidget);
      expect(find.text('When to Call 112 / Go to ER'), findsOneWidget);
      expect(find.text('Histamine (Scombroid) Poisoning'), findsOneWidget);
    });

    testWidgets('Home to 2-Step Viewfinder and Sensory Check flow', (WidgetTester tester) async {
      await tester.pumpWidget(FishGuardApp(
        router: AppRouter.createRouter(initialLocation: AppRoutes.home),
      ));
      await tester.pumpAndSettle();

      // Tap Primary CTA
      await tester.tap(find.text('Scan Fish (2-Step AI)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ScannerViewfinderScreen), findsOneWidget);
      expect(find.text('Step 1: Frame the whole fish'), findsOneWidget);

      // Tap Shutter -> Advance to Step 2
      await tester.tap(find.byIcon(Icons.camera_alt_rounded).last);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Step 2: Focus on Eye & Gill close-up'), findsOneWidget);

      // Tap Shutter again -> Open Sensory Check Bottom Sheet
      await tester.tap(find.byIcon(Icons.camera_alt_rounded).last);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('10s Sensory Check'), findsOneWidget);

      // Scroll to button if needed and tap
      final seeResultBtn = find.text('Calculate Safety Verdict');
      await tester.ensureVisible(seeResultBtn);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(seeResultBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(VerdictScreen), findsOneWidget);
      expect(find.text('Safe to Buy'), findsOneWidget);

      // Tap Done button -> returns to Home
      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Recent Scans item taps open Verdict Screen', (WidgetTester tester) async {
      await tester.pumpWidget(FishGuardApp(
        router: AppRouter.createRouter(initialLocation: AppRoutes.home),
      ));
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(element);
      final repo = container.read(recentScansRepositoryProvider);
      await repo.addScan(const RecentScanModel(
        species: 'Kembung',
        time: 'Yesterday, 06:40 AM',
        freshnessScore: 62,
        verdict: 'CAUTION',
        verdictColor: AppColors.verdictCaution,
        verdictBg: AppColors.verdictCautionBg,
        isCaution: true,
      ));

      container.read(recentScansViewModelProvider.notifier).loadScans();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Tap Kembung Caution item
      final kembungFinder = find.text('Kembung');
      await tester.ensureVisible(kembungFinder);
      await tester.pumpAndSettle();
      await tester.tap(kembungFinder);
      await tester.pumpAndSettle();

      expect(find.byType(VerdictScreen), findsOneWidget);
      expect(find.text('Caution Advised'), findsOneWidget);
      expect(find.text('62%'), findsOneWidget);
    });
  });
}
