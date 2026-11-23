import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../models/poisoning_condition_model.dart';

/// Single Responsibility widget that renders medical guidance for a specific condition.
class PoisoningConditionCard extends StatelessWidget {
  final PoisoningConditionModel condition;

  const PoisoningConditionCard({
    super.key,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Tag & Onset Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: condition.tagBg,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  condition.tagName,
                  style: AppTypography.caption2(color: condition.tagColor)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    condition.onsetTime,
                    style: AppTypography.caption1(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),

          // Title & Species subtitle
          Text(condition.title, style: AppTypography.headline(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.xxs),
          Text(condition.subtitle, style: AppTypography.footnote(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.m),

          // Symptoms Subheader
          Text(
            'Key Symptoms:',
            style: AppTypography.subheadline(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...condition.symptoms.map((s) => _buildBullet(s)),

          const SizedBox(height: AppSpacing.m),

          // First-Aid Subheader
          Text(
            'First-Aid Action:',
            style: AppTypography.subheadline(color: AppColors.primary)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...condition.firstAidSteps.map((f) => _buildCheckItem(f)),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(text, style: AppTypography.footnote(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, color: AppColors.verdictSafe, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(text, style: AppTypography.footnote(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
