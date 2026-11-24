import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget that renders the Traffic-Light Hero Verdict Banner and Radial Gauge.
/// Enhanced with smooth animated radial sweep and count-up interpolation.
class VerdictHeroCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final int score;

  const VerdictHeroCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(width: AppSpacing.m),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.title1(color: color),
                  ),
                  Text(
                    'Biological Freshness Index',
                    style: AppTypography.footnote(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          // Animated Radial Gauge with Fluid Sweep & Number Interpolation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: score / 100.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final currentPercent = (value * 100).round();
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6.0,
                      color: color,
                      backgroundColor: color.withAlpha(40),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '$currentPercent%',
                    style: AppTypography.headline(color: color),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
