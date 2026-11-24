import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Clean, scalable animated vector illustrations for the 3-step onboarding walkthrough.
/// Rendered using smooth Canvas math for high DPI displays without bitmap assets.
/// Equipped with test guards to avoid blocking widget test runners.

// ---------------------------------------------------------------------------
// 1. Instant Wet-Market Safety (Fish Scanner + Laser Sweep)
// ---------------------------------------------------------------------------

class OnboardingIllustration1 extends StatefulWidget {
  const OnboardingIllustration1({super.key});

  @override
  State<OnboardingIllustration1> createState() => _OnboardingIllustration1State();
}

class _OnboardingIllustration1State extends State<OnboardingIllustration1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    final isTest = const bool.fromEnvironment('FLUTTER_TEST') ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 260,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ScannerVectorPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _ScannerVectorPainter extends CustomPainter {
  final double progress;

  _ScannerVectorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft glowing background circle with breathing pulse
    final glowRadius = w * (0.40 + 0.04 * math.sin(progress * math.pi));
    final glowPaint = Paint()
      ..color = AppColors.primaryLight.withAlpha((120 + 40 * progress).round())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), glowRadius, glowPaint);

    // 2. Minimalist Fish Silhouette with gentle aquatic float
    final floatY = math.sin(progress * 2 * math.pi) * 3.5;
    final fishPaint = Paint()
      ..color = AppColors.primaryDark.withAlpha(220)
      ..style = PaintingStyle.fill;

    final fishPath = Path();
    // Torpedo fish body
    fishPath.moveTo(w * 0.22, h * 0.50 + floatY);
    fishPath.quadraticBezierTo(w * 0.40, h * 0.32 + floatY, w * 0.70, h * 0.45 + floatY);
    // Forked tail
    fishPath.lineTo(w * 0.84, h * 0.36 + floatY);
    fishPath.lineTo(w * 0.78, h * 0.50 + floatY);
    fishPath.lineTo(w * 0.84, h * 0.64 + floatY);
    fishPath.lineTo(w * 0.70, h * 0.55 + floatY);
    fishPath.quadraticBezierTo(w * 0.40, h * 0.68 + floatY, w * 0.22, h * 0.50 + floatY);
    fishPath.close();
    canvas.drawPath(fishPath, fishPaint);

    // Fish eye ring and dot
    final eyeRing = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.32, h * 0.48 + floatY), 8.0, eyeRing);

    final eyePupil = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.32, h * 0.48 + floatY), 4.5, eyePupil);

    // Gill arc
    final gillPaint = Paint()
      ..color = AppColors.card.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.42, h * 0.50 + floatY), width: 18, height: 26),
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

    // Corner pulse
    final cornerNudge = math.sin(progress * math.pi) * 2.0;

    // Top-left corner
    canvas.drawLine(Offset(rx - cornerNudge, ry + corner), Offset(rx - cornerNudge, ry - cornerNudge), reticlePaint);
    canvas.drawLine(Offset(rx - cornerNudge, ry - cornerNudge), Offset(rx + corner, ry - cornerNudge), reticlePaint);

    // Top-right corner
    canvas.drawLine(Offset(rx + rw - corner, ry - cornerNudge), Offset(rx + rw + cornerNudge, ry - cornerNudge), reticlePaint);
    canvas.drawLine(Offset(rx + rw + cornerNudge, ry - cornerNudge), Offset(rx + rw + cornerNudge, ry + corner), reticlePaint);

    // Bottom-left corner
    canvas.drawLine(Offset(rx - cornerNudge, ry + rh - corner), Offset(rx - cornerNudge, ry + rh + cornerNudge), reticlePaint);
    canvas.drawLine(Offset(rx - cornerNudge, ry + rh + cornerNudge), Offset(rx + corner, ry + rh + cornerNudge), reticlePaint);

    // Bottom-right corner
    canvas.drawLine(Offset(rx + rw - corner, ry + rh + cornerNudge), Offset(rx + rw + cornerNudge, ry + rh + cornerNudge), reticlePaint);
    canvas.drawLine(Offset(rx + rw + cornerNudge, ry + rh + cornerNudge), Offset(rx + rw + cornerNudge, ry + rh - corner), reticlePaint);

    // 4. Scanning horizontal laser beam sweeping up and down
    final laserY = ry + 8 + (rh - 16) * progress;
    final beamGradient = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withAlpha(0),
          AppColors.primary.withAlpha(220),
          AppColors.primary.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(rx, laserY - 1.5, rw, 3));
    canvas.drawRect(Rect.fromLTWH(rx + 4, laserY - 1.5, rw - 8, 3), beamGradient);

    // Laser glow aura
    final beamHalo = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withAlpha(80),
          AppColors.primary.withAlpha(0),
        ],
      ).createShader(Rect.fromCenter(center: Offset(w / 2, laserY), width: rw * 0.7, height: 16));
    canvas.drawRect(Rect.fromLTWH(rx + 8, laserY - 8, rw - 16, 16), beamHalo);
  }

  @override
  bool shouldRepaint(covariant _ScannerVectorPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 2. Works 100% Offline (Smartphone + Radar Waves + Neural Chip)
// ---------------------------------------------------------------------------

class OnboardingIllustration2 extends StatefulWidget {
  const OnboardingIllustration2({super.key});

  @override
  State<OnboardingIllustration2> createState() => _OnboardingIllustration2State();
}

class _OnboardingIllustration2State extends State<OnboardingIllustration2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    final isTest = const bool.fromEnvironment('FLUTTER_TEST') ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 260,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _OfflineVectorPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _OfflineVectorPainter extends CustomPainter {
  final double progress;

  _OfflineVectorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Radiating offline wireless radar waves behind smartphone
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + i * 0.33) % 1.0;
      final ringRadius = w * (0.28 + ringProgress * 0.22);
      final ringAlpha = ((1.0 - ringProgress) * 110).round();

      final wavePaint = Paint()
        ..color = AppColors.primary.withAlpha(ringAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(w / 2, h / 2 - 8), ringRadius, wavePaint);
    }

    // Soft ambient glow circle
    final glow = Paint()
      ..color = const Color(0xFFE3F2FD).withAlpha(160)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.40, glow);

    // 2. Smartphone Chassis with subtle vertical bob
    final bobY = math.sin(progress * 2 * math.pi) * 2.5;
    final phonePaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    final phoneBorder = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final pw = w * 0.46;
    final ph = h * 0.70;
    final px = (w - pw) / 2;
    final py = (h - ph) / 2 + bobY;
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

    // 3. Lightning Chip Badge in center of phone with breathing scale
    final chipScale = 1.0 + 0.08 * math.sin(progress * 2 * math.pi);
    final chipCenter = Offset(w / 2, py + ph * 0.46);

    final chipGlowPaint = Paint()
      ..color = AppColors.primary.withAlpha(50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(chipCenter, 32 * chipScale, chipGlowPaint);

    final chipPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(chipCenter, 24 * chipScale, chipPaint);

    // Lightning bolt inside chip
    final boltPath = Path();
    final bx = chipCenter.dx;
    final by = chipCenter.dy;
    boltPath.moveTo(bx + 2, by - 14);
    boltPath.lineTo(bx - 7, by - 2);
    boltPath.lineTo(bx + 1, by - 2);
    boltPath.lineTo(bx - 2, by + 10);
    boltPath.lineTo(bx + 7, by - 3);
    boltPath.lineTo(bx - 1, by - 3);
    boltPath.close();

    final boltPaint = Paint()
      ..color = AppColors.textInverse
      ..style = PaintingStyle.fill;
    canvas.drawPath(boltPath, boltPaint);

    // 4. Floating Offline Shield Pill at bottom
    final shieldPill = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    final shieldBorder = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, py + ph - 2), width: 110, height: 28),
      const Radius.circular(14),
    );
    canvas.drawRRect(pillRect, shieldPill);
    canvas.drawRRect(pillRect, shieldBorder);

    // Offline Green status indicator dot inside pill
    final dotPaint = Paint()
      ..color = AppColors.verdictSafe
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2 - 32, py + ph - 2), 4, dotPaint);

    // Small simulated signal bar line
    final linePaint = Paint()
      ..color = AppColors.textSecondary.withAlpha(160)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w / 2 - 18, py + ph - 2),
      Offset(w / 2 + 32, py + ph - 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OfflineVectorPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 3. Detect Invisible Hazards (Bio Shield + Orbiting Hazard Particles)
// ---------------------------------------------------------------------------

class OnboardingIllustration3 extends StatefulWidget {
  const OnboardingIllustration3({super.key});

  @override
  State<OnboardingIllustration3> createState() => _OnboardingIllustration3State();
}

class _OnboardingIllustration3State extends State<OnboardingIllustration3>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    final isTest = const bool.fromEnvironment('FLUTTER_TEST') ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 260,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ShieldVectorPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _ShieldVectorPainter extends CustomPainter {
  final double progress;

  _ShieldVectorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft glowing green ambient background with breathing pulse
    final glowRadius = w * (0.42 + 0.03 * math.sin(progress * 2 * math.pi));
    final glow = Paint()
      ..color = AppColors.verdictSafeBg.withAlpha((180 + 40 * math.sin(progress * 2 * math.pi)).round())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), glowRadius, glow);

    // 2. Large Health & Hazard Shield with gentle scale float
    final shieldBob = math.sin(progress * 2 * math.pi) * 3.0;
    final shieldPath = Path();
    shieldPath.moveTo(w / 2, h * 0.20 + shieldBob);
    shieldPath.lineTo(w * 0.74, h * 0.28 + shieldBob);
    shieldPath.quadraticBezierTo(w * 0.74, h * 0.60 + shieldBob, w / 2, h * 0.80 + shieldBob);
    shieldPath.quadraticBezierTo(w * 0.26, h * 0.60 + shieldBob, w * 0.26, h * 0.28 + shieldBob);
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
    checkPath.moveTo(w * 0.40, h * 0.48 + shieldBob);
    checkPath.lineTo(w * 0.47, h * 0.56 + shieldBob);
    checkPath.lineTo(w * 0.62, h * 0.40 + shieldBob);

    final checkPaint = Paint()
      ..color = AppColors.textInverse
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(checkPath, checkPaint);

    // 3. Orbiting Hazard Threat Indicators (Histamine, Formalin, Bacteria)
    final hazards = [
      _HazardNode(
        label: 'Histamine',
        color: AppColors.verdictCaution,
        angleOffset: 0.0,
        radiusX: w * 0.42,
        radiusY: h * 0.34,
      ),
      _HazardNode(
        label: 'Formalin',
        color: AppColors.verdictAvoid,
        angleOffset: 2.1,
        radiusX: w * 0.44,
        radiusY: h * 0.32,
      ),
      _HazardNode(
        label: 'Spoilage',
        color: AppColors.primaryDark,
        angleOffset: 4.2,
        radiusX: w * 0.40,
        radiusY: h * 0.36,
      ),
    ];

    for (final hazard in hazards) {
      final angle = progress * 2 * math.pi + hazard.angleOffset;
      final nodeX = w / 2 + math.cos(angle) * hazard.radiusX;
      final nodeY = h / 2 + math.sin(angle) * hazard.radiusY;

      // Glow halo
      final nodeHalo = Paint()
        ..color = hazard.color.withAlpha(50)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(nodeX, nodeY), 10, nodeHalo);

      // Node dot
      final nodeDot = Paint()
        ..color = hazard.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(nodeX, nodeY), 6, nodeDot);

      // Deflection ring
      final ringPaint = Paint()
        ..color = hazard.color.withAlpha(140)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(nodeX, nodeY), 9, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShieldVectorPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _HazardNode {
  final String label;
  final Color color;
  final double angleOffset;
  final double radiusX;
  final double radiusY;

  const _HazardNode({
    required this.label,
    required this.color,
    required this.angleOffset,
    required this.radiusX,
    required this.radiusY,
  });
}
