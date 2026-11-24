import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/scan_result_model.dart';
import '../models/recent_scan_model.dart';

/// Abstract contract for fetching and mutating recent scan records (DIP).
abstract class RecentScansRepository {
  Future<List<RecentScanModel>> fetchRecentScans();
  Future<void> addScan(RecentScanModel scan);
  Future<void> addScanResult(ScanResultModel result);
  Future<void> deleteScan(int index);
}

/// Mock in-memory implementation for development and testing.
class MockRecentScansRepository implements RecentScansRepository {
  final List<RecentScanModel> _scans = [];

  @override
  Future<List<RecentScanModel>> fetchRecentScans() async {
    // Simulate brief offline storage fetch
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return List.unmodifiable(_scans);
  }

  @override
  Future<void> addScan(RecentScanModel scan) async {
    _scans.insert(0, scan);
  }

  @override
  Future<void> addScanResult(ScanResultModel result) async {
    await addScan(RecentScanModel.fromScanResult(result));
  }

  @override
  Future<void> deleteScan(int index) async {
    if (index >= 0 && index < _scans.length) {
      _scans.removeAt(index);
    }
  }
}

/// Riverpod provider for the repository.
/// Can be overridden in tests using [ProviderScope(overrides: ...)].
final recentScansRepositoryProvider = Provider<RecentScansRepository>((ref) {
  return MockRecentScansRepository();
});
