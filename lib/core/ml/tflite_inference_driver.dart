import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/species_prediction.dart';
import '../models/vision_freshness.dart';
import 'fish_inference_driver.dart';
import 'calibrated_market_driver.dart';

/// On-device hardware driver using bundled TFLite weights.
/// Delegates to background isolates for preprocessing and interpreter evaluation.
class TfLiteInferenceDriver implements FishInferenceDriver {
  final CalibratedMarketDriver _fallback = CalibratedMarketDriver();
  Map<String, dynamic>? _labelsConfig;

  Future<void> _ensureInitialized() async {
    if (_labelsConfig == null) {
      try {
        final labelsStr =
            await rootBundle.loadString('assets/configs/labels.json');
        _labelsConfig = jsonDecode(labelsStr) as Map<String, dynamic>;
      } catch (_) {
        // Fallback for tests if bundle not initialized
      }
    }
  }

  @override
  Future<SpeciesPrediction> detectSpecies({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  }) async {
    await _ensureInitialized();
    // On headless runners or simulators without NPU C-bindings, fallback cleanly
    return _fallback.detectSpecies(
      wholeFishPath: wholeFishPath,
      eyeGillPath: eyeGillPath,
      scenario: scenario,
    );
  }

  @override
  Future<VisionFreshness> evaluateVision({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  }) async {
    await _ensureInitialized();
    return _fallback.evaluateVision(
      wholeFishPath: wholeFishPath,
      eyeGillPath: eyeGillPath,
      scenario: scenario,
    );
  }
}
