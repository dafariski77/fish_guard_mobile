library;

import '../models/scan_result_model.dart';

/// Strongly-typed route arguments passed between screens.
/// Decouples route parameters from monolithic widget constructors (DIP).
class VerdictRouteArgs {
  final String speciesName;
  final int score;
  final bool isCaution;
  final bool isAvoid;
  final String smell;
  final String texture;
  final String storage;
  final ScanResultModel? scanResult;

  const VerdictRouteArgs({
    required this.speciesName,
    required this.score,
    this.isCaution = false,
    this.isAvoid = false,
    this.smell = 'fresh_sea',
    this.texture = 'bounces_back',
    this.storage = 'packed_in_ice',
    this.scanResult,
  });

  /// Factory helper for fallback defaults
  factory VerdictRouteArgs.defaultSafe() {
    return const VerdictRouteArgs(
      speciesName: 'Tongkol (Bullet Tuna)',
      score: 88,
      isCaution: false,
      isAvoid: false,
    );
  }

  /// Factory adapter creating route args from a contract-compliant [ScanResultModel]
  factory VerdictRouteArgs.fromScanResult(ScanResultModel result) {
    return VerdictRouteArgs(
      speciesName: result.species.displayName,
      score: result.vision.combinedFreshnessScore.round(),
      isCaution: result.verdict.isCaution,
      isAvoid: result.verdict.isAvoid,
      smell: result.sensory.smell,
      texture: result.sensory.texture,
      storage: result.sensory.storage,
      scanResult: result,
    );
  }
}
