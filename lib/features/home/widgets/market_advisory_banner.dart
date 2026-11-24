import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../models/market_advisory_model.dart';

/// Dynamic, non-alarmist market weather & freshness advisory reminder banner.
/// Replaces the static danger banner with helpful, time-sensitive advice.
class MarketAdvisoryBanner extends StatefulWidget {
  final DateTime? mockTime;

  const MarketAdvisoryBanner({
    super.key,
    this.mockTime,
  });

  @override
  State<MarketAdvisoryBanner> createState() => _MarketAdvisoryBannerState();
}

class _MarketAdvisoryBannerState extends State<MarketAdvisoryBanner> {
  int _tipIndex = 0;

  @override
  Widget build(BuildContext context) {
    final advisory = MarketAdvisoryModel.fromTime(widget.mockTime);
    final currentTip = advisory.tips[_tipIndex % advisory.tips.length];

    return InkWell(
      onTap: () {
        AppMotion.tapHaptic();
        setState(() {
          _tipIndex = (_tipIndex + 1) % advisory.tips.length;
        });
      },
      borderRadius: AppRadius.borderCard,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: advisory.backgroundColor,
          borderRadius: AppRadius.borderCard,
          border: Border.all(color: advisory.borderColor, width: 1.2),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Weather / Temperature Pill + Session Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: advisory.accentColor.withAlpha(25),
                    borderRadius: AppRadius.borderButton,
                  ),
                  child: Icon(
                    advisory.icon,
                    color: advisory.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advisory.sessionTitle,
                        style: AppTypography.headline(color: AppColors.textPrimary)
                            .copyWith(fontSize: 15),
                      ),
                      Text(
                        advisory.temperatureLabel,
                        style: AppTypography.caption1(color: advisory.accentColor)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: advisory.accentColor.withAlpha(20),
                    borderRadius: AppRadius.borderFull,
                    border: Border.all(
                      color: advisory.accentColor.withAlpha(40),
                    ),
                  ),
                  child: Text(
                    advisory.badgeText,
                    style: AppTypography.caption2(color: advisory.accentColor)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),

            // Tip Content with Tap-to-cycle hint
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    currentTip,
                    style: AppTypography.footnote(color: AppColors.textPrimary)
                        .copyWith(height: 1.35),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.sync_rounded,
                  color: advisory.accentColor.withAlpha(120),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
