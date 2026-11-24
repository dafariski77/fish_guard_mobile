import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fish_guard_mobile/core/theme/theme.dart';
import 'package:fish_guard_mobile/core/routing/routing.dart';
import 'package:fish_guard_mobile/features/home/models/recent_scan_model.dart';
import 'package:fish_guard_mobile/features/home/repositories/recent_scans_repository.dart';
import 'package:fish_guard_mobile/features/home/viewmodels/recent_scans_viewmodel.dart';
import 'package:fish_guard_mobile/features/history/screens/history_screen.dart';
import 'package:fish_guard_mobile/features/verdict/screens/verdict_screen.dart';

class _FakeHistoryRepo implements RecentScansRepository {
  final List<RecentScanModel> items = [];

  @override
  Future<List<RecentScanModel>> fetchRecentScans() async => List.unmodifiable(items);

  @override
  Future<void> addScan(RecentScanModel scan) async => items.insert(0, scan);

  @override
  Future<void> addScanResult(dynamic result) async {}

  @override
  Future<void> deleteScan(int index) async {
    if (index >= 0 && index < items.length) items.removeAt(index);
  }

  @override
  Future<void> clearAll() async {
    items.clear();
  }
}

void main() {
  group('HistoryScreen UI & Search/Filter Tests', () {
    testWidgets('Shows empty state when no scans exist', (tester) async {
      final fakeRepo = _FakeHistoryRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentScansRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Inspection History'), findsOneWidget);
      expect(find.text('No Saved Inspections'), findsOneWidget);
    });

    testWidgets('Displays list, filters by search query and chips', (tester) async {
      final fakeRepo = _FakeHistoryRepo();
      fakeRepo.items.addAll([
        const RecentScanModel(
          species: 'Tongkol',
          time: 'Today, 07:15 AM',
          freshnessScore: 88,
          verdict: 'SAFE',
          verdictColor: AppColors.verdictSafe,
          verdictBg: AppColors.verdictSafeBg,
          isCaution: false,
        ),
        const RecentScanModel(
          species: 'Kembung',
          time: 'Yesterday, 06:40 AM',
          freshnessScore: 62,
          verdict: 'CAUTION',
          verdictColor: AppColors.verdictCaution,
          verdictBg: AppColors.verdictCautionBg,
          isCaution: true,
        ),
        const RecentScanModel(
          species: 'Bandeng Spoiled',
          time: '20 Nov, 08:10 AM',
          freshnessScore: 35,
          verdict: 'AVOID',
          verdictColor: AppColors.verdictAvoid,
          verdictBg: AppColors.verdictAvoidBg,
          isCaution: false,
          isAvoid: true,
        ),
      ]);

      final router = AppRouter.createRouter(initialLocation: AppRoutes.history);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentScansRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      final element = tester.element(find.byType(HistoryScreen));
      final container = ProviderScope.containerOf(element);
      await container.read(recentScansViewModelProvider.notifier).loadScans();
      await tester.pumpAndSettle();

      expect(find.text('Tongkol'), findsOneWidget);
      expect(find.text('Kembung'), findsOneWidget);
      expect(find.text('Bandeng Spoiled'), findsOneWidget);

      // Filter via search
      await tester.enterText(find.byType(TextField), 'kembung');
      await tester.pumpAndSettle();

      expect(find.text('Kembung'), findsOneWidget);
      expect(find.text('Tongkol'), findsNothing);
      expect(find.text('Bandeng Spoiled'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Tap 'Avoid' chip
      await tester.tap(find.text('Avoid'));
      await tester.pumpAndSettle();

      expect(find.text('Bandeng Spoiled'), findsOneWidget);
      expect(find.text('Tongkol'), findsNothing);
      expect(find.text('Kembung'), findsNothing);

      // Tap the item to navigate to verdict
      await tester.tap(find.text('Bandeng Spoiled'));
      await tester.pumpAndSettle();

      expect(find.byType(VerdictScreen), findsOneWidget);
      expect(find.text('Do Not Buy (High Risk)'), findsOneWidget);

      // Tap back button in VerdictScreen AppBar
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Verified: Returns to HistoryScreen, NOT HomeScreen!
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('Inspection History'), findsOneWidget);
    });
  });
}
