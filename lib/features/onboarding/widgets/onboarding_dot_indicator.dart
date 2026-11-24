import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Reusable Apple-style animated pill dot indicator for carousels.
/// Expands fluidly with easeInOutCubic curve on the active step.
class OnboardingDotIndicator extends StatelessWidget {
  final int totalCount;
  final int currentIndex;

  const OnboardingDotIndicator({
    super.key,
    required this.totalCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          height: 8.0,
          width: isActive ? 28.0 : 8.0,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: AppRadius.borderFull,
          ),
        );
      }),
    );
  }
}
