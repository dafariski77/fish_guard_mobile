import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget: Displays detected species, intrinsic risk badge, and confidence.
class VerdictSpeciesCard extends StatelessWidget {
  final String speciesName;
  final String riskTier;
  final int? confidencePercent;

  const VerdictSpeciesCard({
    super.key,
    required this.speciesName,
    this.riskTier = 'HIGH HISTAMINE',
    this.confidencePercent,
  });

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor) = switch (riskTier.toUpperCase()) {
      var r when r.contains('HISTAMINE') => (AppColors.riskHistamineText, AppColors.riskHistamineBg),
      var r when r.contains('CIGUATERA') => (AppColors.riskCiguateraText, AppColors.riskCiguateraBg),
      var r when r.contains('LOW') => (AppColors.riskLowText, AppColors.riskLowBg),
      _ => (AppColors.riskUnknownText, AppColors.riskUnknownBg),
    };

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.borderButton,
            ),
            child: const Icon(
              Icons.set_meal_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        speciesName,
                        style: AppTypography.headline(color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (confidencePercent != null)
                      Text(
                        '$confidencePercent% match',
                        style: AppTypography.caption1(color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    riskTier,
                    style: AppTypography.caption2(color: textColor)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
