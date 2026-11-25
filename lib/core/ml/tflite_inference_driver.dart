import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/species_prediction.dart';
import '../models/vision_freshness.dart';
import '../utils/app_logger.dart';
import 'calibrated_market_driver.dart';
import 'cielab_preprocessor.dart';
import 'fish_inference_driver.dart';

/// Cached inference output for a captured image pair so Stage 1 & Stage 2
/// don't re-run redundant interpreter passes for the same capture.
class _CachedPassResult {
  final String key;
  final SpeciesPrediction species;
  final VisionFreshness vision;

  const _CachedPassResult({
    required this.key,
    required this.species,
    required this.vision,
  });
}

/// On-device hardware driver using bundled LiteRT / TFLite models:
/// - `assets/models/detector.tflite`: Stage 1 eye & gill localization `[1, 320, 320, 3] -> [1, 6, 2100]`
/// - `assets/models/classifier.tflite`: Stage 2 multi-task species + CIELab freshness scorer
///
/// Falls back cleanly to [CalibratedMarketDriver] when running without image
/// paths (e.g., unit tests or demo scenarios) or on platforms without TFLite
/// native C-bindings (e.g., headless test runners).
class TfLiteInferenceDriver implements FishInferenceDriver {
  static const String _detectorAsset = 'assets/models/detector.tflite';
  static const String _classifierAsset = 'assets/models/classifier.tflite';
  static const String _labelsAsset = 'assets/configs/labels.json';
  static const double _detectorConfThreshold = 0.35;

  final CalibratedMarketDriver _fallback = CalibratedMarketDriver();
  final CielabPreprocessor preprocessor;

  Interpreter? _detector;
  Interpreter? _classifier;
  Map<String, dynamic>? _labelsConfig;
  bool _tfliteUnavailable = false;
  bool _initialized = false;
  _CachedPassResult? _lastPass;

  TfLiteInferenceDriver({
    this.preprocessor = const CielabPreprocessor(),
  });

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final labelsStr = await rootBundle.loadString(_labelsAsset);
      _labelsConfig = jsonDecode(labelsStr) as Map<String, dynamic>;
    } catch (_) {
      // Headless tests may not have asset bundle initialized
    }

    try {
      final options = InterpreterOptions();
      _detector = await Interpreter.fromAsset(_detectorAsset, options: options);
      _classifier =
          await Interpreter.fromAsset(_classifierAsset, options: options);
      await AppLogger.info(
        'TFLite',
        'Loaded detector & classifier interpreters successfully.',
      );
    } catch (e, st) {
      // Native libtensorflowlite_c may be unavailable in test/simulator environments
      _tfliteUnavailable = true;
      _detector?.close();
      _classifier?.close();
      _detector = null;
      _classifier = null;
      await AppLogger.warn(
        'TFLite',
        'Interpreter init unavailable, using fallback: $e',
      );
      if (st.toString().isNotEmpty) {
        // Keep stack trace in debugPrint only
      }
    }
  }

  /// Runs the two-stage TFLite pipeline if image files exist and native TFLite
  /// interpreters are loaded; returns `null` if fallback should be used.
  Future<_CachedPassResult?> _runTfLitePipeline({
    String? wholeFishPath,
    String? eyeGillPath,
  }) async {
    await _ensureInitialized();
    if (_tfliteUnavailable || _detector == null || _classifier == null) {
      return null;
    }

    final primaryPath = wholeFishPath ?? eyeGillPath;
    final closeUpPath = eyeGillPath ?? wholeFishPath;
    if (primaryPath == null || closeUpPath == null) {
      return null;
    }

    final cacheKey = '$primaryPath|$closeUpPath';
    if (_lastPass?.key == cacheKey) {
      return _lastPass;
    }

    final wfFile = File(primaryPath);
    final cuFile = File(closeUpPath);
    if (!await wfFile.exists() || !await cuFile.exists()) {
      return null;
    }

    final wfBytes = await wfFile.readAsBytes();
    final cuBytes = primaryPath == closeUpPath ? wfBytes : await cuFile.readAsBytes();

    final wfImage = preprocessor.decodeImage(wfBytes);
    final cuImage = primaryPath == closeUpPath
        ? wfImage
        : preprocessor.decodeImage(cuBytes);
    if (wfImage == null || cuImage == null) {
      return null;
    }

    // 1. Stage 1: Eye & Gill Detection ([1, 320, 320, 3] -> [1, 6, 2100])
    final detInput = preprocessor.preprocessForDetector(cuImage, inputSize: 320);
    final detOutput = List.generate(
      1,
      (_) => List.generate(6, (_) => List<double>.filled(2100, 0.0)),
    );
    try {
      _detector!.run(detInput, detOutput);
    } on Object catch (e, st) {
      final inShapes =
          _detector!.getInputTensors().map((t) => '${t.name}:${t.shape}:${t.type}').join(', ');
      final outShapes =
          _detector!.getOutputTensors().map((t) => '${t.name}:${t.shape}:${t.type}').join(', ');
      await AppLogger.warn(
        'TFLite',
        'Stage 1 detector.run failed ($e) | in=[$inShapes] out=[$outShapes]; using calibrated fallback.',
      );
      if (st.toString().isNotEmpty) {
        // Logged via debugPrint in AppLogger.warn
      }
      return null;
    }

    final boxes = _decodeDetectorBoxes(detOutput[0]);

    // 2. Crop eye & gill regions with 15% padding and convert to CIELab
    final eyeCrop = preprocessor.cropAndResize(
      cuImage,
      boxes.eyeBbox,
      size: 224,
      paddingRatio: 0.15,
    );
    final gillCrop = preprocessor.cropAndResize(
      cuImage,
      boxes.gillBbox,
      size: 224,
      paddingRatio: 0.15,
    );

    final wfTensor = preprocessor.preprocessWholeFishRgb(wfImage, inputSize: 224);
    final eyeLabTensor = preprocessor.preprocessCropCielab(eyeCrop, inputSize: 224);
    final gillLabTensor = preprocessor.preprocessCropCielab(gillCrop, inputSize: 224);

    // 3. Stage 2: Multi-task Classifier
    // Map inputs dynamically by tensor name so input order never mismatches.
    final inputTensors = _classifier!.getInputTensors();
    final inputs = <Object>[];
    for (final tensor in inputTensors) {
      final name = tensor.name.toLowerCase();
      if (name.contains('eye')) {
        inputs.add(eyeLabTensor);
      } else if (name.contains('gill')) {
        inputs.add(gillLabTensor);
      } else {
        inputs.add(wfTensor);
      }
    }

    final outputTensors = _classifier!.getOutputTensors();
    final outputs = <int, Object>{};
    for (int i = 0; i < outputTensors.length; i++) {
      final shape = outputTensors[i].shape;
      final cols = shape.length > 1 ? shape[1] : 1;
      outputs[i] = [List<double>.filled(cols, 0.0)];
    }

    try {
      _classifier!.runForMultipleInputs(inputs, outputs);
    } on Object catch (e) {
      final inShapes =
          inputTensors.map((t) => '${t.name}:${t.shape}:${t.type}').join(', ');
      final outShapes =
          outputTensors.map((t) => '${t.name}:${t.shape}:${t.type}').join(', ');
      await AppLogger.warn(
        'TFLite',
        'Stage 2 classifier.runForMultipleInputs failed ($e) | in=[$inShapes] out=[$outShapes]; using calibrated fallback.',
      );
      return null;
    }

    // Extract species probabilities ([1, 11]) and freshness scores ([1, 1] x 2)
    List<double> speciesProbs = List<double>.filled(11, 0.0);
    final scalarScores = <double>[];

    for (int i = 0; i < outputTensors.length; i++) {
      final outList = (outputs[i] as List<List<double>>).first;
      if (outList.any((v) => !v.isFinite)) {
        await AppLogger.warn(
          'TFLite',
          'Model output tensor $i contained NaN/Inf; falling back to calibrated driver.',
        );
        return null;
      }
      if (outList.length >= 11) {
        speciesProbs = outList;
      } else if (outList.isNotEmpty) {
        scalarScores.add(outList.first.clamp(0.0, 1.0));
      }
    }

    final eyeScore = scalarScores.isNotEmpty ? scalarScores[0] : 0.75;
    final gillScore = scalarScores.length > 1 ? scalarScores[1] : eyeScore;
    final combinedScore = ((0.45 * eyeScore) + (0.55 * gillScore)) * 100.0;
    final grade = combinedScore >= 70.0
        ? 'SAFE'
        : (combinedScore >= 50.0 ? 'CAUTION' : 'AVOID');

    final species = _buildSpeciesPrediction(speciesProbs);
    final vision = VisionFreshness(
      eyeBbox: boxes.eyeBbox,
      gillBbox: boxes.gillBbox,
      eyeScore: _round(eyeScore, 3),
      gillScore: _round(gillScore, 3),
      combinedFreshnessScore: _round(combinedScore, 1),
      grade: grade,
    );

    await AppLogger.info(
      'TFLite',
      'Inference OK: species=${species.label} (${species.confidence}), score=${vision.combinedFreshnessScore}',
    );

    final pass = _CachedPassResult(
      key: cacheKey,
      species: species,
      vision: vision,
    );
    _lastPass = pass;
    return pass;
  }

  /// Decodes `[6, 2100]` YOLO-Nano detector output into best eye & gill boxes.
  ({List<double> eyeBbox, List<double> gillBbox}) _decodeDetectorBoxes(
    List<List<double>> raw,
  ) {
    double bestEyeConf = -1.0;
    double bestGillConf = -1.0;
    List<double> eyeBbox = const [0.42, 0.31, 0.12, 0.12];
    List<double> gillBbox = const [0.55, 0.40, 0.18, 0.22];

    for (int i = 0; i < 2100; i++) {
      final cx = raw[0][i];
      final cy = raw[1][i];
      final w = raw[2][i].abs().clamp(0.05, 0.95);
      final h = raw[3][i].abs().clamp(0.05, 0.95);

      final eyeConf = _sigmoid(raw[4][i]);
      final gillConf = _sigmoid(raw[5][i]);

      if (eyeConf >= _detectorConfThreshold && eyeConf > bestEyeConf) {
        bestEyeConf = eyeConf;
        eyeBbox = _cxcywhToXywh(cx, cy, w, h);
      }
      if (gillConf >= _detectorConfThreshold && gillConf > bestGillConf) {
        bestGillConf = gillConf;
        gillBbox = _cxcywhToXywh(cx, cy, w, h);
      }
    }

    return (eyeBbox: eyeBbox, gillBbox: gillBbox);
  }

  List<double> _cxcywhToXywh(double cx, double cy, double w, double h) {
    final xMin = (cx - w / 2.0).clamp(0.0, 0.95);
    final yMin = (cy - h / 2.0).clamp(0.0, 0.95);
    return [xMin, yMin, w, h];
  }

  double _sigmoid(double x) => 1.0 / (1.0 + math.exp(-x.clamp(-20.0, 20.0)));

  SpeciesPrediction _buildSpeciesPrediction(List<double> probs) {
    int bestIdx = 0;
    double bestProb = -1.0;
    for (int i = 0; i < probs.length; i++) {
      if (probs[i] > bestProb) {
        bestProb = probs[i];
        bestIdx = i;
      }
    }

    final classes = (_labelsConfig?['species_classes'] as List<dynamic>?)
            ?.cast<String>() ??
        const [
          'tongkol',
          'kembung',
          'cakalang',
          'bandeng',
          'kakap',
          'gurame',
          'nila',
          'lele',
          'kerapu',
          'tenggiri',
          'unknown',
        ];

    final label =
        bestIdx < classes.length ? classes[bestIdx] : 'unknown';
    final metadataMap =
        _labelsConfig?['species_metadata'] as Map<String, dynamic>?;
    final meta = metadataMap?[label] as Map<String, dynamic>?;

    return SpeciesPrediction(
      label: label,
      displayName: (meta?['display_name'] as String?) ?? label,
      confidence: _round(bestProb.clamp(0.0, 1.0), 3),
      intrinsicRisk:
          (meta?['intrinsic_risk'] as String?) ?? 'UNKNOWN_RISK',
    );
  }

  double _round(double value, int decimals) {
    if (!value.isFinite) return 0.0;
    final factor = math.pow(10, decimals).toDouble();
    return (value * factor).round() / factor;
  }

  @override
  Future<SpeciesPrediction> detectSpecies({
    String? wholeFishPath,
    String? eyeGillPath,
    String scenario = 'fresh_iced',
  }) async {
    final tfliteResult = await _runTfLitePipeline(
      wholeFishPath: wholeFishPath,
      eyeGillPath: eyeGillPath,
    );
    if (tfliteResult != null) {
      return tfliteResult.species;
    }

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
    final tfliteResult = await _runTfLitePipeline(
      wholeFishPath: wholeFishPath,
      eyeGillPath: eyeGillPath,
    );
    if (tfliteResult != null) {
      return tfliteResult.vision;
    }

    return _fallback.evaluateVision(
      wholeFishPath: wholeFishPath,
      eyeGillPath: eyeGillPath,
      scenario: scenario,
    );
  }

  void dispose() {
    _detector?.close();
    _classifier?.close();
    _detector = null;
    _classifier = null;
  }
}
