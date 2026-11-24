import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/scan_result_model.dart';
import '../models/recent_scan_model.dart';

/// Abstract contract for fetching and mutating recent scan records (DIP).
abstract class RecentScansRepository {
  Future<List<RecentScanModel>> fetchRecentScans();
  Future<void> addScan(RecentScanModel scan);
  Future<void> addScanResult(ScanResultModel result);
  Future<void> deleteScan(int index);
  Future<void> clearAll();
}

/// Persistent [SharedPreferences] implementation of [RecentScansRepository].
/// Guarantees that scans are stored persistently on device flash memory across app restarts.
class SharedPreferencesRecentScansRepository implements RecentScansRepository {
  static const String _storageKey = 'fish_guard_recent_scans_v1';
  static const int _maxSavedScans = 100;

  final SharedPreferences? prefs;
  List<RecentScanModel>? _cache;

  SharedPreferencesRecentScansRepository({this.prefs});

  Future<SharedPreferences?> _getPrefs() async {
    if (prefs != null) return prefs;
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RecentScanModel>> fetchRecentScans() async {
    if (_cache != null) {
      return List.unmodifiable(_cache!);
    }

    final prefs = await _getPrefs();
    if (prefs == null) {
      _cache = [];
      return List.unmodifiable(_cache!);
    }

    try {
      final jsonStrings = prefs.getStringList(_storageKey);
      if (jsonStrings == null || jsonStrings.isEmpty) {
        _cache = [];
        return List.unmodifiable(_cache!);
      }

      final items = <RecentScanModel>[];
      for (final raw in jsonStrings) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            items.add(RecentScanModel.fromJson(decoded));
          }
        } catch (_) {
          // Gracefully skip corrupt entries
        }
      }
      _cache = items;
    } catch (_) {
      _cache = [];
    }

    return List.unmodifiable(_cache!);
  }

  @override
  Future<void> addScan(RecentScanModel scan) async {
    if (_cache == null) {
      await fetchRecentScans();
    }

    _cache!.insert(0, scan);
    if (_cache!.length > _maxSavedScans) {
      _cache!.removeLast();
    }

    await _persist();
  }

  @override
  Future<void> addScanResult(ScanResultModel result) async {
    await addScan(RecentScanModel.fromScanResult(result));
  }

  @override
  Future<void> deleteScan(int index) async {
    if (_cache == null) {
      await fetchRecentScans();
    }

    if (index >= 0 && index < _cache!.length) {
      _cache!.removeAt(index);
      await _persist();
    }
  }

  @override
  Future<void> clearAll() async {
    _cache = [];
    final prefs = await _getPrefs();
    if (prefs != null) {
      try {
        await prefs.remove(_storageKey);
      } catch (_) {}
    }
  }

  Future<void> _persist() async {
    if (_cache == null) return;
    final prefs = await _getPrefs();
    if (prefs == null) return;

    try {
      final jsonStrings = _cache!.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonStrings);
    } catch (_) {}
  }
}

/// In-memory mock implementation for development and testing.
class MockRecentScansRepository implements RecentScansRepository {
  final List<RecentScanModel> _scans = [];

  @override
  Future<List<RecentScanModel>> fetchRecentScans() async {
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

  @override
  Future<void> clearAll() async {
    _scans.clear();
  }
}

/// Riverpod provider for the repository.
/// Defaults to [SharedPreferencesRecentScansRepository] for persistent storage.
final recentScansRepositoryProvider = Provider<RecentScansRepository>((ref) {
  return SharedPreferencesRecentScansRepository();
});
