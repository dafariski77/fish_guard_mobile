import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget for top camera controls (Close, Quality, Torch, Prompt).
class ViewfinderTopControls extends StatelessWidget {
  final int step;
  final bool isTorchOn;
  final VoidCallback onClose;
  final VoidCallback onToggleTorch;

  const ViewfinderTopControls({
    super.key,
    required this.step,
    required this.isTorchOn,
    required this.onClose,
    required this.onToggleTorch,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.cameraPillBg,
                      shape: const CircleBorder(),
                    ),
                  ),

                  // Quality Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cameraPillBg,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.verdictSafe,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Sharp & Well Lit',
                          style: AppTypography.caption1(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Torch Toggle Button
                  IconButton(
                    onPressed: onToggleTorch,
                    icon: Icon(
                      isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: isTorchOn ? Colors.amber : Colors.white,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.cameraPillBg,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),

              // Instruction Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cameraPillBg,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(color: Colors.white.withAlpha(40)),
                ),
                child: Text(
                  step == 1
                      ? 'Step 1: Frame the whole fish'
                      : 'Step 2: Focus on Eye & Gill close-up',
                  style: AppTypography.headline(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
