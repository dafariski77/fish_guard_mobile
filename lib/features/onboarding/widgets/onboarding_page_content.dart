import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../models/onboarding_item.dart';

/// Single Responsibility widget that renders the content of an onboarding slide.
/// Features a smooth spring fade & slide-in transition on page changes.
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
      child: TweenAnimationBuilder<double>(
        key: ValueKey(item.title),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 16 * (1.0 - value)),
              child: child,
            ),
          );
        },
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
      ),
    );
  }
}
