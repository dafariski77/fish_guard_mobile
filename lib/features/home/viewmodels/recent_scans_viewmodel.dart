import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recent_scan_model.dart';
import '../repositories/recent_scans_repository.dart';
import 'recent_scans_state.dart';

/// ViewModel managing state and business logic for Recent Scans.
/// Adheres to SOLID:
/// - Single Responsibility: Coordinates state transitions between repo and UI.
/// - Dependency Inversion: Depends on abstract [RecentScansRepository].
class RecentScansViewModel extends Notifier<RecentScansState> {
  late final RecentScansRepository _repository;

  @override
  RecentScansState build() {
    _repository = ref.watch(recentScansRepositoryProvider);
    // Asynchronously fetch initial scans and guard with ref.mounted
    Future.microtask(() => loadScans());
    return const RecentScansState(status: RecentScansStatus.loading);
  }

  /// Fetches recent inspections from the repository.
  Future<void> loadScans() async {
    state = state.copyWith(status: RecentScansStatus.loading);
    try {
      final items = await _repository.fetchRecentScans();
      if (!ref.mounted) return;
      state = state.copyWith(
        status: RecentScansStatus.loaded,
        scans: items,
        errorMessage: null,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: RecentScansStatus.error,
        errorMessage: 'Failed to load inspection history: $e',
      );
    }
  }

  /// Adds a new scan and refreshes the list.
  Future<void> addScan(RecentScanModel scan) async {
    await _repository.addScan(scan);
    if (!ref.mounted) return;
    await loadScans();
  }

  /// Removes an item at the given index.
  Future<void> removeScan(int index) async {
    await _repository.deleteScan(index);
    if (!ref.mounted) return;
    await loadScans();
  }
}

/// Global provider for the RecentScansViewModel.
final recentScansViewModelProvider =
    NotifierProvider<RecentScansViewModel, RecentScansState>(
  RecentScansViewModel.new,
);
