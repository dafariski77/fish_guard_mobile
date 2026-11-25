import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Result of pre-capture image quality validation.
class ImageQualityReport {
  final bool passed;
  final double averageLuminance;
  final double sharpnessVariance;
  final String? warningMessage;

  const ImageQualityReport({
    required this.passed,
    required this.averageLuminance,
    required this.sharpnessVariance,
    this.warningMessage,
  });
}

/// Pure-Dart image preprocessor implementing FishGuard's two-stage vision spec:
/// - Stage 1 detector input: [1, 320, 320, 3] Float32 ImageNet-normalized RGB
/// - Stage 2 whole fish input: [1, 224, 224, 3] Float32 ImageNet-normalized RGB
/// - Stage 2 eye/gill crops: [1, 224, 224, 3] Float32 CIE 1976 (L*, a*, b*) D65 normalized
class CielabPreprocessor {
  static const List<double> _imagenetMean = [0.485, 0.456, 0.406];
  static const List<double> _imagenetStd = [0.229, 0.224, 0.225];

  const CielabPreprocessor();

  /// Decodes raw image bytes (JPEG/PNG) into an [img.Image].
  img.Image? decodeImage(Uint8List bytes) {
    return img.decodeImage(bytes);
  }

  /// Evaluates exposure (luminance) and sharpness (Laplacian-like variance).
  ImageQualityReport validateQuality(img.Image image) {
    final sample = img.copyResize(image, width: 160, height: 160);
    final w = sample.width;
    final h = sample.height;
    final gray = Float64List(w * h);

    double lumSum = 0.0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = sample.getPixel(x, y);
        final l = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
        gray[y * w + x] = l;
        lumSum += l;
      }
    }
    final avgLum = lumSum / (w * h);

    // Discrete 3x3 Laplacian variance on grayscale
    double lapSum = 0.0;
    double lapSqSum = 0.0;
    int count = 0;
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final idx = y * w + x;
        final lap = -4.0 * gray[idx] +
            gray[idx - 1] +
            gray[idx + 1] +
            gray[idx - w] +
            gray[idx + w];
        lapSum += lap;
        lapSqSum += lap * lap;
        count++;
      }
    }
    final meanLap = count > 0 ? lapSum / count : 0.0;
    final variance = count > 0 ? (lapSqSum / count) - (meanLap * meanLap) : 0.0;

    String? warning;
    if (avgLum < 40.0) {
      warning = 'Lighting is too dark. Turn on torch / flash.';
    } else if (avgLum > 225.0) {
      warning = 'Glare detected. Reposition camera to avoid reflection.';
    } else if (variance < 100.0) {
      warning = 'Hold the camera steady and tap to focus.';
    }

    return ImageQualityReport(
      passed: warning == null,
      averageLuminance: avgLum,
      sharpnessVariance: variance,
      warningMessage: warning,
    );
  }

  /// Builds Stage 1 detector input tensor [1, 320, 320, 3] (NHWC Float32).
  List<List<List<List<double>>>> preprocessForDetector(
    img.Image image, {
    int inputSize = 320,
  }) {
    return _buildRgbTensor(image, inputSize);
  }

  /// Builds Stage 2 whole-fish RGB input tensor [1, 224, 224, 3] (NHWC Float32).
  List<List<List<List<double>>>> preprocessWholeFishRgb(
    img.Image image, {
    int inputSize = 224,
  }) {
    return _buildRgbTensor(image, inputSize);
  }

  /// Crops a normalized bounding box `[xMin, yMin, width, height]` with padding
  /// and resizes to `[size, size]`.
  img.Image cropAndResize(
    img.Image image,
    List<double> bbox, {
    int size = 224,
    double paddingRatio = 0.15,
  }) {
    final w = image.width.toDouble();
    final h = image.height.toDouble();

    final bx = (bbox.isNotEmpty ? bbox[0] : 0.25).clamp(0.0, 0.95);
    final by = (bbox.length > 1 ? bbox[1] : 0.25).clamp(0.0, 0.95);
    final bw = (bbox.length > 2 ? bbox[2] : 0.25).clamp(0.05, 1.0);
    final bh = (bbox.length > 3 ? bbox[3] : 0.25).clamp(0.05, 1.0);

    final padX = bw * paddingRatio;
    final padY = bh * paddingRatio;

    final x0 = ((bx - padX) * w).round().clamp(0, image.width - 2);
    final y0 = ((by - padY) * h).round().clamp(0, image.height - 2);
    final x1 = ((bx + bw + padX) * w).round().clamp(x0 + 1, image.width);
    final y1 = ((by + bh + padY) * h).round().clamp(y0 + 1, image.height);

    final cropped = img.copyCrop(
      image,
      x: x0,
      y: y0,
      width: x1 - x0,
      height: y1 - y0,
    );
    return img.copyResize(cropped, width: size, height: size);
  }

  /// Builds Stage 2 eye/gill CIELab input tensor `[1, 224, 224, 3]` (NHWC Float32).
  /// Formula: `L_norm = (L - 50.0) / 50.0`, `a_norm = a / 128.0`, `b_norm = b / 128.0`.
  List<List<List<List<double>>>> preprocessCropCielab(
    img.Image crop, {
    int inputSize = 224,
  }) {
    final resized = (crop.width == inputSize && crop.height == inputSize)
        ? crop
        : img.copyResize(crop, width: inputSize, height: inputSize);

    return [
      List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          final p = resized.getPixel(x, y);
          final lab = rgbToLab(p.r.toDouble(), p.g.toDouble(), p.b.toDouble());
          return [
            ((lab[0] - 50.0) / 50.0).clamp(-1.0, 1.0),
            (lab[1] / 128.0).clamp(-1.0, 1.0),
            (lab[2] / 128.0).clamp(-1.0, 1.0),
          ];
        });
      }),
    ];
  }

  /// Converts sRGB `[0..255]` to CIE 1976 (L*, a*, b*) using D65 illuminant.
  static List<double> rgbToLab(double r8, double g8, double b8) {
    final r = _linearizeSrgb(r8 / 255.0);
    final g = _linearizeSrgb(g8 / 255.0);
    final b = _linearizeSrgb(b8 / 255.0);

    // sRGB to CIE XYZ (D65 reference white: Xn=0.95047, Yn=1.00000, Zn=1.08883)
    final x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047;
    final y = (0.2126729 * r + 0.7151522 * g + 0.0721750 * b) / 1.00000;
    final z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883;

    final fx = _labF(x);
    final fy = _labF(y);
    final fz = _labF(z);

    final lStar = 116.0 * fy - 16.0;
    final aStar = 500.0 * (fx - fy);
    final bStar = 200.0 * (fy - fz);

    return [lStar, aStar, bStar];
  }

  static double _linearizeSrgb(double c) {
    return c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _labF(double t) {
    const delta = 6.0 / 29.0;
    const delta3 = delta * delta * delta;
    return t > delta3 ? math.pow(t, 1.0 / 3.0).toDouble() : (t / (3.0 * delta * delta)) + (4.0 / 29.0);
  }

  List<List<List<List<double>>>> _buildRgbTensor(img.Image image, int size) {
    final resized = (image.width == size && image.height == size)
        ? image
        : img.copyResize(image, width: size, height: size);

    return [
      List.generate(size, (y) {
        return List.generate(size, (x) {
          final p = resized.getPixel(x, y);
          return [
            ((p.r / 255.0) - _imagenetMean[0]) / _imagenetStd[0],
            ((p.g / 255.0) - _imagenetMean[1]) / _imagenetStd[1],
            ((p.b / 255.0) - _imagenetMean[2]) / _imagenetStd[2],
          ];
        });
      }),
    ];
  }
}
