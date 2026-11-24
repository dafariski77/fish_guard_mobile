import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';

/// Single Responsibility card widget directing users to the offline poisoning guide.
class FirstAidEntryCard extends StatelessWidget {
  const FirstAidEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppMotion.tapHaptic();
        context.goToFirstAid();
      },
      borderRadius: AppRadius.borderCard,
      child: Container(
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
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: AppRadius.borderButton,
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Color(0xFF2563EB),
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offline Fish Poisoning Guide',
                    style: AppTypography.headline(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
