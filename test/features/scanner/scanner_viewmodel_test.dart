import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fish_guard_mobile/features/scanner/viewmodels/scanner_viewmodel.dart';
import 'package:fish_guard_mobile/features/home/repositories/recent_scans_repository.dart';
import 'package:fish_guard_mobile/core/models/sensory_input.dart';

void main() {
  group('ScannerViewModel Riverpod State & Workflow Tests', () {
    test('Initializes at Step 1 with torch off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(scannerViewModelProvider);
      expect(state.currentStep, 1);
      expect(state.isTorchOn, false);
      expect(state.isProcessing, false);
      expect(state.detectedSpecies, isNull);
    });

    test('Toggles torch state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vm = container.read(scannerViewModelProvider.notifier);
      vm.toggleTorch();
      expect(container.read(scannerViewModelProvider).isTorchOn, true);
      vm.toggleTorch();
      expect(container.read(scannerViewModelProvider).isTorchOn, false);
    });

    test('Two-Phase Workflow: Step 1 -> Step 2 species detection -> Sensory submit -> Saves to repository', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vm = container.read(scannerViewModelProvider.notifier);
      final repo = container.read(recentScansRepositoryProvider);

      final initialScans = await repo.fetchRecentScans();
      final initialCount = initialScans.length;

      // 1. Shutter Step 1: Whole fish
      vm.captureStep1();
      expect(container.read(scannerViewModelProvider).currentStep, 2);

      // 2. Shutter Step 2: Close-up & Species Detection
      final species = await vm.captureStep2AndDetectSpecies();
      expect(species.displayName, contains('Tongkol'));
      expect(container.read(scannerViewModelProvider).detectedSpecies, isNotNull);
      expect(container.read(scannerViewModelProvider).visionFreshness, isNotNull);

      // 3. Sensory submit: Calculate Final Verdict
      final result = await vm.submitSensoryAndCalculateVerdict(
        const SensoryInput(
          smell: 'fresh_sea',
          texture: 'bounces_back',
          storage: 'packed_in_ice',
        ),
      );

      expect(result.verdict.status, 'GREEN');
      expect(result.verdict.isSafe, true);

      // 4. Verify scan was persisted to RecentScansRepository
      final updatedScans = await repo.fetchRecentScans();
      expect(updatedScans.length, initialCount + 1);
      expect(updatedScans.first.species, 'Tongkol (Bullet Tuna)');
      expect(updatedScans.first.freshnessScore, 88);
      expect(updatedScans.first.scanResult, isNotNull);
    });
  });
}
