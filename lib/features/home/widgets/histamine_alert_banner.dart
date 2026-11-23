import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget that renders the high-risk histamine educational banner.
class HistamineAlertBanner extends StatelessWidget {
  const HistamineAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.riskHistamineBg,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: AppColors.riskHistamineText.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: AppColors.riskHistamineText.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.riskHistamineText,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'High Histamine Advisory',
                  style: AppTypography.headline(color: AppColors.riskHistamineText),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Tongkol, Cakalang, & Kembung must be packed in ice. Scombroid histamine forms off-ice within 90 min and cannot be cooked away.',
                  style: AppTypography.footnote(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
