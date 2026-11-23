import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget that renders the Traffic-Light Hero Verdict Banner and Radial Gauge.
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

          // Radial Gauge Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 6.0,
                  color: color,
                  backgroundColor: color.withAlpha(40),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '$score%',
                style: AppTypography.headline(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
