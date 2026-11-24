import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';

/// Hero Floating Scan Action Dock.
/// Ergonomically positioned in the bottom thumb zone with an elevated gradient surface,
/// frosted ambient glow, and two-line action hierarchy to command visual focus.
class HomeScanBottomBar extends StatelessWidget {
  const HomeScanBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.groupedBackground.withAlpha(0),
            AppColors.groupedBackground.withAlpha(220),
            AppColors.groupedBackground,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppMotion.tapHaptic();
            context.goToScanner();
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00897B), // Rich Ocean Teal
                  Color(0xFF005A64), // Deep Marine Navy
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withAlpha(50),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007A87).withAlpha(90),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Highlighted Camera Shutter Lens Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(35),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(80),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),

                // Primary Two-Line Call to Action
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Fish (2-Step AI)',
                        style: AppTypography.headline(color: Colors.white).copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Instant species & freshness verdict',
                        style: AppTypography.footnote(
                          color: Colors.white.withAlpha(210),
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Action Arrow
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
