import '../../../core/models/scan_result_model.dart';
import '../../../core/models/species_prediction.dart';
import '../../../core/models/vision_freshness.dart';

/// Immutable state for the 2-step scanning and sensory check flow.
class ScannerState {
  final int currentStep; // 1: Whole fish, 2: Eye & Gill close-up
  final bool isTorchOn;
  final bool isProcessing;
  final SpeciesPrediction? detectedSpecies;
  final VisionFreshness? visionFreshness;
  final ScanResultModel? lastResult;
  final String? errorMessage;
  final String sampleScenario;
  final String? wholeFishImagePath;
  final String? eyeGillImagePath;

  const ScannerState({
    this.currentStep = 1,
    this.isTorchOn = false,
    this.isProcessing = false,
    this.detectedSpecies,
    this.visionFreshness,
    this.lastResult,
    this.errorMessage,
    this.sampleScenario = 'fresh_iced',
    this.wholeFishImagePath,
    this.eyeGillImagePath,
  });

  factory ScannerState.initial() => const ScannerState();

  ScannerState copyWith({
    int? currentStep,
    bool? isTorchOn,
    bool? isProcessing,
    SpeciesPrediction? detectedSpecies,
    VisionFreshness? visionFreshness,
    ScanResultModel? lastResult,
    String? errorMessage,
    String? sampleScenario,
    String? wholeFishImagePath,
    String? eyeGillImagePath,
  }) {
    return ScannerState(
      currentStep: currentStep ?? this.currentStep,
      isTorchOn: isTorchOn ?? this.isTorchOn,
      isProcessing: isProcessing ?? this.isProcessing,
      detectedSpecies: detectedSpecies ?? this.detectedSpecies,
      visionFreshness: visionFreshness ?? this.visionFreshness,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage,
      sampleScenario: sampleScenario ?? this.sampleScenario,
      wholeFishImagePath: wholeFishImagePath ?? this.wholeFishImagePath,
      eyeGillImagePath: eyeGillImagePath ?? this.eyeGillImagePath,
    );
  }
}
