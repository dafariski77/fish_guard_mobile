import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ml/inference_service.dart';
import '../../../core/ml/hybrid_risk_engine.dart';
import '../../../core/models/scan_result_model.dart';
import '../../../core/models/species_prediction.dart';
import '../../../core/models/vision_freshness.dart';
import '../../../core/models/sensory_input.dart';
import '../../home/repositories/recent_scans_repository.dart';
import '../../home/viewmodels/recent_scans_viewmodel.dart';
import 'scanner_state.dart';

/// ViewModel managing camera viewfinder steps, edge ML inference,
/// and sensory check integration.
class ScannerViewModel extends Notifier<ScannerState> {
  static const _uuid = Uuid();

  @override
  ScannerState build() {
    return ScannerState.initial();
  }

  void toggleTorch() {
    state = state.copyWith(isTorchOn: !state.isTorchOn);
  }

  void setScenario(String scenario) {
    state = state.copyWith(sampleScenario: scenario);
  }

  void reset() {
    state = ScannerState.initial();
  }

  /// Phase 1: Capture whole fish and advance to Step 2
  void captureStep1({String? imagePath}) {
    state = state.copyWith(currentStep: 2);
  }

  /// Phase 2: Capture eye & gill close-up and execute edge vision inference
  Future<SpeciesPrediction> captureStep2AndDetectSpecies({
    String? imagePath,
  }) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final inferenceService = ref.read(fishInferenceServiceProvider);
      final detection = await inferenceService.detectSpeciesAndVision(
        ScanInput(
          eyeGillImagePath: imagePath,
          sampleScenario: state.sampleScenario,
          sensory: const SensoryInput(
            smell: 'fresh_sea',
            texture: 'bounces_back',
            storage: 'packed_in_ice',
          ),
        ),
      );

      if (!ref.mounted) return detection.species;

      state = state.copyWith(
        isProcessing: false,
        detectedSpecies: detection.species,
        visionFreshness: detection.vision,
      );

      return detection.species;
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'Vision detection error: $e',
        );
      }
      rethrow;
    }
  }

  /// Phase 3: Submit sensory observations, evaluate final risk verdict, and persist to history
  Future<ScanResultModel> submitSensoryAndCalculateVerdict(
    SensoryInput sensory,
  ) async {
    state = state.copyWith(isProcessing: true);

    try {
      final species = state.detectedSpecies ??
          const SpeciesPrediction(
            label: 'tongkol',
            displayName: 'Tongkol (Bullet Tuna)',
            confidence: 0.88,
            intrinsicRisk: 'HIGH_HISTAMINE',
          );

      final vision = state.visionFreshness ??
          const VisionFreshness(
            eyeBbox: [0.42, 0.31, 0.12, 0.12],
            gillBbox: [0.55, 0.40, 0.18, 0.22],
            eyeScore: 0.86,
            gillScore: 0.89,
            combinedFreshnessScore: 87.7,
            grade: 'SAFE',
          );

      const riskEngine = HybridRiskEngine();
      final verdict = riskEngine.evaluateVerdict(
        species: species,
        vision: vision,
        sensory: sensory,
      );

      final result = ScanResultModel(
        scanId: _uuid.v4(),
        timestamp: DateTime.now(),
        species: species,
        vision: vision,
        sensory: sensory,
        verdict: verdict,
      );

      // Persist to scan history repository
      final repo = ref.read(recentScansRepositoryProvider);
      await repo.addScanResult(result);

      // Notify RecentScansViewModel to refresh
      try {
        await ref.read(recentScansViewModelProvider.notifier).loadScans();
      } catch (_) {}

      if (ref.mounted) {
        state = state.copyWith(
          isProcessing: false,
          lastResult: result,
        );
      }

      return result;
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'Verdict evaluation error: $e',
        );
      }
      rethrow;
    }
  }
}

/// Global provider for the ScannerViewModel.
final scannerViewModelProvider =
    NotifierProvider<ScannerViewModel, ScannerState>(
  ScannerViewModel.new,
);
