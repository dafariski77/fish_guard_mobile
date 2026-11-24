import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_guard_mobile/core/theme/theme.dart';
import 'package:fish_guard_mobile/core/models/scan_result_model.dart';
import 'package:fish_guard_mobile/core/models/species_prediction.dart';
import 'package:fish_guard_mobile/core/models/vision_freshness.dart';
import 'package:fish_guard_mobile/core/models/sensory_input.dart';
import 'package:fish_guard_mobile/core/models/final_verdict.dart';
import 'package:fish_guard_mobile/features/home/models/recent_scan_model.dart';
import 'package:fish_guard_mobile/features/home/repositories/recent_scans_repository.dart';

void main() {
  group('RecentScanModel Serialization & Persistence Tests', () {
    test('Serializes to JSON and roundtrips with fidelity', () {
      final now = DateTime.now();
      final original = RecentScanModel(
        species: 'Tongkol (Bullet Tuna)',
        time: 'Just now',
        freshnessScore: 88,
        verdict: 'SAFE',
        verdictColor: AppColors.verdictSafe,
        verdictBg: AppColors.verdictSafeBg,
        isCaution: false,
        isAvoid: false,
        timestamp: now,
      );

      final jsonMap = original.toJson();
      final restored = RecentScanModel.fromJson(jsonMap);

      expect(restored.species, 'Tongkol (Bullet Tuna)');
      expect(restored.freshnessScore, 88);
      expect(restored.verdict, 'SAFE');
      expect(restored.isCaution, isFalse);
      expect(restored.isAvoid, isFalse);
      expect(restored.time, 'Just now');
    });

    test('Preserves full ScanResultModel explainability through JSON roundtrip', () {
      final scanResult = ScanResultModel(
        scanId: 'uuid-12345',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        species: const SpeciesPrediction(
          label: 'tongkol',
          displayName: 'Tongkol',
          confidence: 0.92,
          intrinsicRisk: 'HIGH_HISTAMINE',
        ),
        vision: const VisionFreshness(
          eyeBbox: [0.1, 0.1, 0.2, 0.2],
          gillBbox: [0.3, 0.3, 0.2, 0.2],
          eyeScore: 0.85,
          gillScore: 0.90,
          combinedFreshnessScore: 87.5,
          grade: 'SAFE',
        ),
        sensory: const SensoryInput(
          smell: 'fresh_sea',
          texture: 'bounces_back',
          storage: 'packed_in_ice',
        ),
        verdict: const FinalVerdict(
          status: 'GREEN',
          reasons: ['Cornea is crystal clear.', 'Gills deep red.'],
          recommendation: 'Safe to buy.',
        ),
      );

      final original = RecentScanModel.fromScanResult(scanResult);
      final jsonMap = original.toJson();
      final restored = RecentScanModel.fromJson(jsonMap);

      expect(restored.species, 'Tongkol');
      expect(restored.scanResult, isNotNull);
      expect(restored.scanResult!.scanId, 'uuid-12345');
      expect(restored.scanResult!.verdict.reasons, hasLength(2));
      expect(restored.scanResult!.verdict.reasons.first, 'Cornea is crystal clear.');
      expect(restored.time, '5m ago');
    });
  });

  group('SharedPreferencesRecentScansRepository Persistence Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('Saves scans and hydrates from persistent disk storage on app restart', () async {
      // 1. Session 1: User scans a fish
      final repoSession1 = SharedPreferencesRecentScansRepository(prefs: prefs);

      expect(await repoSession1.fetchRecentScans(), isEmpty);

      const scan1 = RecentScanModel(
        species: 'Tongkol',
        time: 'Just now',
        freshnessScore: 85,
        verdict: 'SAFE',
        verdictColor: AppColors.verdictSafe,
        verdictBg: AppColors.verdictSafeBg,
        isCaution: false,
      );

      await repoSession1.addScan(scan1);

      final session1Scans = await repoSession1.fetchRecentScans();
      expect(session1Scans, hasLength(1));
      expect(session1Scans.first.species, 'Tongkol');

      // 2. Session 2: User closes app and opens again (new repository instance reading same SharedPreferences)
      final repoSession2 = SharedPreferencesRecentScansRepository(prefs: prefs);

      final session2Scans = await repoSession2.fetchRecentScans();
      expect(session2Scans, hasLength(1));
      expect(session2Scans.first.species, 'Tongkol');
      expect(session2Scans.first.freshnessScore, 85);
      expect(session2Scans.first.verdict, 'SAFE');

      // 3. Add second scan in Session 2
      const scan2 = RecentScanModel(
        species: 'Kembung',
        time: 'Just now',
        freshnessScore: 60,
        verdict: 'CAUTION',
        verdictColor: AppColors.verdictCaution,
        verdictBg: AppColors.verdictCautionBg,
        isCaution: true,
      );
      await repoSession2.addScan(scan2);

      // 4. Session 3: Simulate another relaunch
      final repoSession3 = SharedPreferencesRecentScansRepository(prefs: prefs);
      final session3Scans = await repoSession3.fetchRecentScans();
      expect(session3Scans, hasLength(2));
      expect(session3Scans[0].species, 'Kembung');
      expect(session3Scans[1].species, 'Tongkol');

      // 5. Delete an item and verify persistence across relaunch
      await repoSession3.deleteScan(0);
      final repoSession4 = SharedPreferencesRecentScansRepository(prefs: prefs);
      final session4Scans = await repoSession4.fetchRecentScans();
      expect(session4Scans, hasLength(1));
      expect(session4Scans.first.species, 'Tongkol');

      // 6. Clear all and verify persistence
      await repoSession4.clearAll();
      final repoSession5 = SharedPreferencesRecentScansRepository(prefs: prefs);
      expect(await repoSession5.fetchRecentScans(), isEmpty);
    });
  });
}
