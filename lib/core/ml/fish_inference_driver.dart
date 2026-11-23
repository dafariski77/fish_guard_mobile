import '../models/species_prediction.dart';
import '../models/vision_freshness.dart';

/// Abstract hardware/driver interface for edge machine learning models (DIP).
abstract class FishInferenceDriver {
  /// Detects species label and confidence from whole fish capture.
  Future<SpeciesPrediction> detectSpecies({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  });

  /// Detects eye/gill bounding boxes and computes vision freshness scores.
  Future<VisionFreshness> evaluateVision({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  });
}
