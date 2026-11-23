import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fish_guard_mobile/core/theme/theme.dart';
import 'package:fish_guard_mobile/features/home/models/recent_scan_model.dart';
import 'package:fish_guard_mobile/features/home/repositories/recent_scans_repository.dart';
import 'package:fish_guard_mobile/features/home/viewmodels/recent_scans_state.dart';
import 'package:fish_guard_mobile/features/home/viewmodels/recent_scans_viewmodel.dart';

class FakeScansRepository implements RecentScansRepository {
  final List<RecentScanModel> items = [];

  @override
  Future<List<RecentScanModel>> fetchRecentScans() async {
    return List.unmodifiable(items);
  }

  @override
  Future<void> addScan(RecentScanModel scan) async {
    items.insert(0, scan);
  }

  @override
  Future<void> addScanResult(dynamic result) async {
    // Adapter implementation
  }

  @override
  Future<void> deleteScan(int index) async {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
    }
  }
}

void main() {
  group('RecentScansViewModel Riverpod Unit Tests', () {
    test('Initializes in loading state and loads scans from repository', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify loading state
      final initialState = container.read(recentScansViewModelProvider);
      expect(initialState.isLoading, isTrue);

      // Explicitly await load completion
      await container.read(recentScansViewModelProvider.notifier).loadScans();

      final loadedState = container.read(recentScansViewModelProvider);
      expect(loadedState.status, RecentScansStatus.loaded);
      expect(loadedState.scans.length, 3);
      expect(loadedState.scans.first.species, 'Tongkol (Bullet Tuna)');
      expect(loadedState.hasRecentCaution, isTrue); // Kembung is caution
    });

    test('addScan inserts item at index 0 and updates state', () async {
      final fakeRepo = FakeScansRepository();
      // Test dependency inversion override using fakeRepo
      final container = ProviderContainer(
        overrides: [
          recentScansRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      const newScan = RecentScanModel(
        species: 'Kakap Merah (Red Snapper)',
        time: 'Just now',
        freshnessScore: 95,
        verdict: 'SAFE',
        verdictColor: AppColors.verdictSafe,
        verdictBg: AppColors.verdictSafeBg,
        isCaution: false,
      );

      final notifier = container.read(recentScansViewModelProvider.notifier);
      await notifier.addScan(newScan);

      final state = container.read(recentScansViewModelProvider);
      expect(state.scans.first.species, 'Kakap Merah (Red Snapper)');
      expect(state.scans.length, 1);
    });
  });
}
