import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';

/// Single Responsibility widget: Fixed bottom action bar for the Home Dashboard.
class HomeScanBottomBar extends StatelessWidget {
  const HomeScanBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.bottomThumbZone,
      decoration: BoxDecoration(
        color: AppColors.card.withAlpha(240),
        border: const Border(
          top: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: SizedBox(
        height: AppSpacing.primaryButtonHeight,
        child: ElevatedButton.icon(
          onPressed: () {
            AppMotion.tapHaptic();
            context.goToScanner();
          },
          icon: const Icon(Icons.camera_alt_rounded, size: 22),
          label: Text(
            'Scan Fish (2-Step AI)',
            style: AppTypography.headline(color: AppColors.textInverse),
          ),
        ),
      ),
    );
  }
}
