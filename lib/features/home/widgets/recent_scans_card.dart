import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';
import '../models/recent_scan_model.dart';

/// Single Responsibility widget displaying the grouped inset list of recent scans.
class RecentScansCard extends StatelessWidget {
  final List<RecentScanModel> items;

  const RecentScansCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return InkWell(
            onTap: () {
              AppMotion.selectionHaptic();
              if (item.scanResult != null) {
                context.goToVerdict(VerdictRouteArgs.fromScanResult(item.scanResult!));
              } else {
                context.goToVerdict(
                  VerdictRouteArgs(
                    speciesName: item.species,
                    score: item.freshnessScore,
                    isCaution: item.isCaution,
                    isAvoid: item.isAvoid,
                  ),
                );
              }
            },
            borderRadius: index == 0
                ? const BorderRadius.vertical(top: Radius.circular(AppRadius.card))
                : (isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.card))
                    : BorderRadius.zero),
            child: Column(
              children: [
                Padding(
                  padding: AppSpacing.listRowPadding,
                  child: Row(
                    children: [
                      // Fish Icon Box
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: AppRadius.borderButton,
                        ),
                        child: const Icon(
                          Icons.set_meal_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),

                      // Title & Timestamp
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.species,
                              style: AppTypography.headline(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              item.time,
                              style: AppTypography.footnote(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      // Verdict Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: item.verdictBg,
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Text(
                          '${item.freshnessScore}% ${item.verdict}',
                          style: AppTypography.caption1(color: item.verdictColor)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 0.5, indent: 68),
              ],
            ),
          );
        }),
      ),
    );
  }
}
