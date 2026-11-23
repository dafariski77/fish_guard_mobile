import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bundled Assets Verification Tests', () {
    test('Config JSON assets exist and can be loaded', () async {
      final labelsStr = await rootBundle.loadString('assets/configs/labels.json');
      expect(labelsStr, contains('detector_classes'));
      expect(labelsStr, contains('tongkol'));

      final riskStr = await rootBundle.loadString('assets/configs/species_risk_config.json');
      expect(riskStr, contains('HIGH_HISTAMINE'));

      final rulesStr = await rootBundle.loadString('assets/configs/risk_engine_rules.json');
      expect(rulesStr, contains('RULE_FORMALIN_DUAL_FLAG'));
    });

    test('Model weights exist and have non-zero size', () async {
      final detectorBytes = await rootBundle.load('assets/models/detector.tflite');
      expect(detectorBytes.lengthInBytes, greaterThan(1000));

      final classifierBytes = await rootBundle.load('assets/models/classifier.tflite');
      expect(classifierBytes.lengthInBytes, greaterThan(1000));
    });

    test('Market test sample images exist', () async {
      final sample1 = await rootBundle.load('assets/samples/tongkol_fresh_iced.jpg');
      expect(sample1.lengthInBytes, greaterThan(500));

      final sample2 = await rootBundle.load('assets/samples/tongkol_spoiled_no_ice.jpg');
      expect(sample2.lengthInBytes, greaterThan(500));

      final sample3 = await rootBundle.load('assets/samples/kembung_formalin_flag.jpg');
      expect(sample3.lengthInBytes, greaterThan(500));
    });
  });
}
