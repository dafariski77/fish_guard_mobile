import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../models/market_advisory_model.dart';

/// Dynamic, non-alarmist market weather & freshness advisory reminder banner.
/// Enhanced with smooth AnimatedSwitcher slide-in tip transitions and tactile spring physics.
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
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final advisory = MarketAdvisoryModel.fromTime(widget.mockTime);
    final currentTip = advisory.tips[_tipIndex % advisory.tips.length];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        AppMotion.tapHaptic();
        setState(() {
          _tipIndex = (_tipIndex + 1) % advisory.tips.length;
        });
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
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
              // Top Bar: Weather / Temperature Pill + Session Title + Live Sensor Beacon
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
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: advisory.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              advisory.temperatureLabel,
                              style: AppTypography.caption1(color: advisory.accentColor)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
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

              // Animated Tip Content with Smooth Slide & Fade Switcher
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        currentTip,
                        key: ValueKey<int>(_tipIndex),
                        style: AppTypography.footnote(color: AppColors.textPrimary)
                            .copyWith(height: 1.35),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AnimatedRotation(
                    turns: _tipIndex * 0.5,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.sync_rounded,
                      color: advisory.accentColor.withAlpha(140),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
