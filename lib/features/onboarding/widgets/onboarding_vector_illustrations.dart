import 'package:material_ui/material_ui.dart';
import 'dart:math' as math;
import '../../../core/theme/theme.dart';

/// Clean, scalable vector illustrations for the 3-step onboarding walkthrough.
/// Rendered using smooth Canvas math for high DPI displays without bitmap assets.

class OnboardingIllustration1 extends StatelessWidget {
  const OnboardingIllustration1({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 260,
      child: CustomPaint(
        painter: _ScannerVectorPainter(),
      ),
    );
  }
}

class _ScannerVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft glowing background circle
    final glowPaint = Paint()
      ..color = AppColors.primaryLight.withAlpha(140)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.42, glowPaint);

    // 2. Minimalist Fish Silhouette
    final fishPaint = Paint()
      ..color = AppColors.primaryDark.withAlpha(220)
      ..style = PaintingStyle.fill;

    final fishPath = Path();
    // Torpedo fish body
    fishPath.moveTo(w * 0.22, h * 0.50);
    fishPath.quadraticBezierTo(w * 0.40, h * 0.32, w * 0.70, h * 0.45);
    // Forked tail
    fishPath.lineTo(w * 0.84, h * 0.36);
    fishPath.lineTo(w * 0.78, h * 0.50);
    fishPath.lineTo(w * 0.84, h * 0.64);
    fishPath.lineTo(w * 0.70, h * 0.55);
    fishPath.quadraticBezierTo(w * 0.40, h * 0.68, w * 0.22, h * 0.50);
    fishPath.close();
    canvas.drawPath(fishPath, fishPaint);

    // Fish eye ring and dot
    final eyeRing = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.32, h * 0.48), 8.0, eyeRing);

    final eyePupil = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.32, h * 0.48), 4.5, eyePupil);

    // Gill arc
    final gillPaint = Paint()
      ..color = AppColors.card.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.42, h * 0.50), width: 18, height: 26),
      -math.pi / 2,
      math.pi,
      false,
      gillPaint,
    );

    // 3. AI Reticle / Scanner Bounding Box
    final reticlePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final rw = w * 0.72;
    final rh = h * 0.60;
    final rx = (w - rw) / 2;
    final ry = (h - rh) / 2;
    const corner = 20.0;

    // Top-left corner
    canvas.drawLine(Offset(rx, ry + corner), Offset(rx, ry), reticlePaint);
    canvas.drawLine(Offset(rx, ry), Offset(rx + corner, ry), reticlePaint);

    // Top-right corner
    canvas.drawLine(Offset(rx + rw - corner, ry), Offset(rx + rw, ry), reticlePaint);
    canvas.drawLine(Offset(rx + rw, ry), Offset(rx + rw, ry + corner), reticlePaint);

    // Bottom-left corner
    canvas.drawLine(Offset(rx, ry + rh - corner), Offset(rx, ry + rh), reticlePaint);
    canvas.drawLine(Offset(rx, ry + rh), Offset(rx + corner, ry + rh), reticlePaint);

    // Bottom-right corner
    canvas.drawLine(Offset(rx + rw - corner, ry + rh), Offset(rx + rw, ry + rh), reticlePaint);
    canvas.drawLine(Offset(rx + rw, ry + rh), Offset(rx + rw, ry + rh - corner), reticlePaint);

    // Scanning horizontal laser beam
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withAlpha(0),
          AppColors.primary.withAlpha(200),
          AppColors.primary.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(rx, ry + rh * 0.48, rw, 3));
    canvas.drawRect(Rect.fromLTWH(rx + 4, ry + rh * 0.48, rw - 8, 3), beamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingIllustration2 extends StatelessWidget {
  const OnboardingIllustration2({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 260,
      child: CustomPaint(
        painter: _OfflineVectorPainter(),
      ),
    );
  }
}

class _OfflineVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft glowing circle
    final glow = Paint()
      ..color = const Color(0xFFE3F2FD)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.42, glow);

    // Smartphone Chassis
    final phonePaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    final phoneBorder = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final pw = w * 0.46;
    final ph = h * 0.72;
    final px = (w - pw) / 2;
    final py = (h - ph) / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(px, py, pw, ph),
      const Radius.circular(22),
    );
    canvas.drawRRect(rrect, phonePaint);
    canvas.drawRRect(rrect, phoneBorder);

    // Phone screen area
    final screenPaint = Paint()
      ..color = AppColors.canvas
      ..style = PaintingStyle.fill;
    final screenRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(px + 7, py + 12, pw - 14, ph - 24),
      const Radius.circular(16),
    );
    canvas.drawRRect(screenRRect, screenPaint);

    // Lightning Chip Badge in center of phone
    final chipPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2 - 6), 26, chipPaint);

    // Lightning bolt inside chip
    final boltPath = Path();
    boltPath.moveTo(w / 2 + 2, h / 2 - 20);
    boltPath.lineTo(w / 2 - 8, h / 2 - 4);
    boltPath.lineTo(w / 2 + 1, h / 2 - 4);
    boltPath.lineTo(w / 2 - 2, h / 2 + 10);
    boltPath.lineTo(w / 2 + 8, h / 2 - 6);
    boltPath.lineTo(w / 2 - 1, h / 2 - 6);
    boltPath.close();

    final boltPaint = Paint()
      ..color = AppColors.textInverse
      ..style = PaintingStyle.fill;
    canvas.drawPath(boltPath, boltPaint);

    // Floating Offline Shield Pill
    final shieldPill = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    final shieldBorder = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, py + ph + 4), width: 120, height: 32),
      const Radius.circular(16),
    );
    canvas.drawRRect(pillRect, shieldPill);
    canvas.drawRRect(pillRect, shieldBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingIllustration3 extends StatelessWidget {
  const OnboardingIllustration3({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 260,
      child: CustomPaint(
        painter: _ShieldVectorPainter(),
      ),
    );
  }
}

class _ShieldVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glowing green tint circle
    final glow = Paint()
      ..color = AppColors.verdictSafeBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.42, glow);

    // Large Health & Hazard Shield
    final shieldPath = Path();
    shieldPath.moveTo(w / 2, h * 0.20);
    shieldPath.lineTo(w * 0.74, h * 0.28);
    shieldPath.quadraticBezierTo(w * 0.74, h * 0.60, w / 2, h * 0.80);
    shieldPath.quadraticBezierTo(w * 0.26, h * 0.60, w * 0.26, h * 0.28);
    shieldPath.close();

    final shieldFill = Paint()
      ..color = AppColors.verdictSafe
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, shieldFill);

    // Shield inner border highlight
    final shieldInner = Paint()
      ..color = AppColors.textInverse.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(shieldPath, shieldInner);

    // Bold Checkmark inside shield
    final checkPath = Path();
    checkPath.moveTo(w * 0.40, h * 0.48);
    checkPath.lineTo(w * 0.47, h * 0.56);
    checkPath.lineTo(w * 0.62, h * 0.40);

    final checkPaint = Paint()
      ..color = AppColors.textInverse
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
