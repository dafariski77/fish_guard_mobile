import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:fish_guard_mobile/core/ml/cielab_preprocessor.dart';
import 'package:fish_guard_mobile/core/ml/tflite_inference_driver.dart';

void main() {
  group('CielabPreprocessor Tests', () {
    const preprocessor = CielabPreprocessor();

    test('Converts pure white and pure black sRGB to expected D65 L*a*b*', () {
      final white = CielabPreprocessor.rgbToLab(255, 255, 255);
      expect(white[0], closeTo(100.0, 0.2));
      expect(white[1], closeTo(0.0, 0.2));
      expect(white[2], closeTo(0.0, 0.2));

      final black = CielabPreprocessor.rgbToLab(0, 0, 0);
      expect(black[0], closeTo(0.0, 0.1));
      expect(black[1], closeTo(0.0, 0.1));
      expect(black[2], closeTo(0.0, 0.1));
    });

    test('Builds detector [1, 320, 320, 3] and classifier [1, 224, 224, 3] tensors', () {
      final sample = img.Image(width: 400, height: 300);
      img.fill(sample, color: img.ColorRgb8(180, 60, 70));

      final det = preprocessor.preprocessForDetector(sample);
      expect(det.length, 1);
      expect(det[0].length, 320);
      expect(det[0][0].length, 320);
      expect(det[0][0][0].length, 3);

      final wf = preprocessor.preprocessWholeFishRgb(sample);
      expect(wf.length, 1);
      expect(wf[0].length, 224);
      expect(wf[0][0].length, 224);
      expect(wf[0][0][0].length, 3);

      final crop = preprocessor.cropAndResize(sample, [0.4, 0.3, 0.15, 0.15]);
      expect(crop.width, 224);
      expect(crop.height, 224);

      final lab = preprocessor.preprocessCropCielab(crop);
      expect(lab.length, 1);
      expect(lab[0].length, 224);
      expect(lab[0][0].length, 224);
      expect(lab[0][0][0].length, 3);
      // Normalized CIELab values must stay within [-1.0, 1.0]
      for (final ch in lab[0][0][0]) {
        expect(ch, inInclusiveRange(-1.0, 1.0));
      }
    });

    test('Validates exposure and rejects too-dark images', () {
      final dark = img.Image(width: 100, height: 100);
      img.fill(dark, color: img.ColorRgb8(10, 10, 10));

      final report = preprocessor.validateQuality(dark);
      expect(report.passed, isFalse);
      expect(report.averageLuminance, lessThan(40.0));
      expect(report.warningMessage, contains('too dark'));
    });
  });

  group('TfLiteInferenceDriver Headless Fallback Tests', () {
    test('Falls back cleanly to calibrated driver in headless test environment', () async {
      final driver = TfLiteInferenceDriver();
      final species = await driver.detectSpecies(scenario: 'fresh_iced');
      final vision = await driver.evaluateVision(scenario: 'fresh_iced');

      expect(species.label, 'tongkol');
      expect(species.confidence, greaterThan(0.7));
      expect(vision.grade, 'SAFE');
      expect(vision.combinedFreshnessScore, greaterThan(70.0));
      driver.dispose();
    });
  });
}
