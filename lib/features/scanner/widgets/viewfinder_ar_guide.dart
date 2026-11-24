import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget that renders the augmented reality framing guides
/// with animated breathing corners and a dynamic holographic laser scan sweep.
class ViewfinderArGuide extends StatelessWidget {
  final int step;
  final double breatheOpacity;
  final double scanProgress;

  const ViewfinderArGuide({
    super.key,
    required this.step,
    required this.breatheOpacity,
    this.scanProgress = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ArGuidePainter(
        step: step,
        breatheOpacity: breatheOpacity,
        scanProgress: scanProgress,
      ),
    );
  }
}

class _ArGuidePainter extends CustomPainter {
  final int step;
  final double breatheOpacity;
  final double scanProgress;

  _ArGuidePainter({
    required this.step,
    required this.breatheOpacity,
    required this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final guidePaint = Paint()
      ..color = AppColors.cameraArGuide.withValues(alpha: breatheOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final double rx, ry, boxW, boxH;

    if (step == 1) {
      // Step 1: Whole Fish Oval Guide with Corner Brackets
      boxW = w * 0.85;
      boxH = h * 0.40;
      rx = (w - boxW) / 2;
      ry = (h - boxH) / 2 - 20;
      const c = 26.0;

      // Draw 4 corner reticles
      canvas.drawLine(Offset(rx, ry + c), Offset(rx, ry), guidePaint);
      canvas.drawLine(Offset(rx, ry), Offset(rx + c, ry), guidePaint);

      canvas.drawLine(Offset(rx + boxW - c, ry), Offset(rx + boxW, ry), guidePaint);
      canvas.drawLine(Offset(rx + boxW, ry), Offset(rx + boxW, ry + c), guidePaint);

      canvas.drawLine(Offset(rx, ry + boxH - c), Offset(rx, ry + boxH), guidePaint);
      canvas.drawLine(Offset(rx, ry + boxH), Offset(rx + c, ry + boxH), guidePaint);

      canvas.drawLine(Offset(rx + boxW - c, ry + boxH), Offset(rx + boxW, ry + boxH), guidePaint);
      canvas.drawLine(Offset(rx + boxW, ry + boxH), Offset(rx + boxW, ry + boxH - c), guidePaint);
    } else {
      // Step 2: Zoomed-in Target Box for Eye & Gill
      final targetSize = w * 0.65;
      boxW = targetSize;
      boxH = targetSize;
      rx = (w - targetSize) / 2;
      ry = (h - targetSize) / 2 - 20;
      const c = 32.0;

      // Draw active targeting brackets
      canvas.drawLine(Offset(rx, ry + c), Offset(rx, ry), guidePaint);
      canvas.drawLine(Offset(rx, ry), Offset(rx + c, ry), guidePaint);

      canvas.drawLine(Offset(rx + targetSize - c, ry), Offset(rx + targetSize, ry), guidePaint);
      canvas.drawLine(Offset(rx + targetSize, ry), Offset(rx + targetSize, ry + c), guidePaint);

      canvas.drawLine(Offset(rx, ry + targetSize - c), Offset(rx, ry + targetSize), guidePaint);
      canvas.drawLine(Offset(rx, ry + targetSize), Offset(rx + c, ry + targetSize), guidePaint);

      canvas.drawLine(Offset(rx + targetSize - c, ry + targetSize), Offset(rx + targetSize, ry + targetSize), guidePaint);
      canvas.drawLine(Offset(rx + targetSize, ry + targetSize), Offset(rx + targetSize, ry + targetSize - c), guidePaint);
    }

    // Dynamic Holographic Laser Scan Sweep
    final scanY = ry + (boxH * scanProgress);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.cameraArGuide.withValues(alpha: 0.0),
          AppColors.cameraArGuide.withValues(alpha: 0.75),
          AppColors.cameraArGuide.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(rx, scanY, boxW, 2.5))
      ..strokeWidth = 2.5;

    canvas.drawLine(Offset(rx + 8, scanY), Offset(rx + boxW - 8, scanY), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _ArGuidePainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.breatheOpacity != breatheOpacity ||
        oldDelegate.scanProgress != scanProgress;
  }
}
