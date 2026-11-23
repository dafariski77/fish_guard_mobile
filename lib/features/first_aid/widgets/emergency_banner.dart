import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget that renders the urgent Emergency ER Red Flags alert.
class EmergencyBanner extends StatelessWidget {
  const EmergencyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.verdictAvoidBg,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: AppColors.verdictAvoidBorder),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.verdictAvoid,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                'When to Call 112 / Go to ER',
                style: AppTypography.headline(color: AppColors.verdictAvoid),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Seek immediate emergency medical attention if you or a family member experience:',
            style: AppTypography.footnote(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildBullet('Swelling of the lips, tongue, or throat (Anaphylaxis)'),
          _buildBullet('Shortness of breath, wheezing, or chest tightness'),
          _buildBullet('Loss of consciousness, extreme dizziness, or confusion'),
          _buildBullet('Inability to keep fluids down for more than 12 hours'),
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
            child: Text(
              text,
              style: AppTypography.footnote(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
