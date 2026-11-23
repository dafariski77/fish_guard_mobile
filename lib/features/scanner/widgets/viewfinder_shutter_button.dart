import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget that renders the ergonomic circular camera shutter button.
class ViewfinderShutterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ViewfinderShutterButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppSpacing.shutterOuterSize,
        height: AppSpacing.shutterOuterSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4.0),
        ),
        child: Center(
          child: Container(
            width: AppSpacing.shutterInnerSize,
            height: AppSpacing.shutterInnerSize,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
