import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget that renders the augmented reality framing guides.
class ViewfinderArGuide extends StatelessWidget {
  final int step;
  final double breatheOpacity;

  const ViewfinderArGuide({
    super.key,
    required this.step,
    required this.breatheOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ArGuidePainter(
        step: step,
        breatheOpacity: breatheOpacity,
      ),
    );
  }
}

class _ArGuidePainter extends CustomPainter {
  final int step;
  final double breatheOpacity;

  _ArGuidePainter({required this.step, required this.breatheOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final guidePaint = Paint()
      ..color = AppColors.cameraArGuide.withValues(alpha: breatheOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    if (step == 1) {
      // Step 1: Whole Fish Oval Guide with Corner Brackets
      final boxW = w * 0.85;
      final boxH = h * 0.40;
      final rx = (w - boxW) / 2;
      final ry = (h - boxH) / 2 - 20;
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
      final rx = (w - targetSize) / 2;
      final ry = (h - targetSize) / 2 - 20;
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

      // Center crosshair
      final cx = rx + targetSize / 2;
      final cy = ry + targetSize / 2;
      final crossPaint = Paint()
        ..color = AppColors.cameraArGuide.withValues(alpha: breatheOpacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawLine(Offset(cx - 14, cy), Offset(cx + 14, cy), crossPaint);
      canvas.drawLine(Offset(cx, cy - 14), Offset(cx, cy + 14), crossPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArGuidePainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.breatheOpacity != breatheOpacity;
  }
}
