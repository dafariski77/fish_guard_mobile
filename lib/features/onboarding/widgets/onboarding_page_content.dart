import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../models/onboarding_item.dart';

/// Single Responsibility widget that renders the content of an onboarding slide.
class OnboardingPageContent extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPageContent({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scalable Vector Illustration
          item.illustration,
          const SizedBox(height: AppSpacing.xxxl),

          // Title
          Text(
            item.title,
            style: AppTypography.title1(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.m),

          // Subtitle
          Text(
            item.description,
            style: AppTypography.body(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
