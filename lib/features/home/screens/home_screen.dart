import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';
import '../viewmodels/recent_scans_state.dart';
import '../viewmodels/recent_scans_viewmodel.dart';
import '../widgets/histamine_alert_banner.dart';
import '../widgets/recent_scans_card.dart';
import '../widgets/first_aid_entry_card.dart';
import '../widgets/home_scan_bottom_bar.dart';

/// Home Dashboard Screen (v3.0 Wet-Market Ergonomics).
/// Refactored to MVVM using Riverpod [ConsumerWidget].
/// Separates UI presentation from state management and async repository operations.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentScansState = ref.watch(recentScansViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        backgroundColor: AppColors.groupedBackground,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FishGuard',
              style: AppTypography.title1(color: AppColors.textPrimary),
            ),
            Text(
              'Smart Seafood Safety',
              style: AppTypography.subheadline(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.l),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.borderFull,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.subtle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  '100% Offline',
                  style: AppTypography.caption1(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(recentScansViewModelProvider.notifier).loadScans();
          },
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              const SizedBox(height: AppSpacing.m),

              // Dynamic Contextual Market Advisory Banner
              const HistamineAlertBanner(),
              const SizedBox(height: AppSpacing.l),

              // Horizontal Capabilities Ribbon
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFeaturePill(
                      icon: Icons.set_meal_rounded,
                      title: '6 Species AI',
                      subtitle: 'Scombridae & Reef',
                      color: const Color(0xFF007A87),
                      bg: const Color(0xFFE0F2F1),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _buildFeaturePill(
                      icon: Icons.timer_outlined,
                      title: '10s Sensory',
                      subtitle: 'Smell & Texture',
                      color: const Color(0xFFD97706),
                      bg: const Color(0xFFFEF3C7),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _buildFeaturePill(
                      icon: Icons.offline_bolt_rounded,
                      title: 'Edge LiteRT',
                      subtitle: 'Zero Cloud Data',
                      color: const Color(0xFF16A34A),
                      bg: const Color(0xFFDCFCE7),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Section Header: Recent Scans
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT INSPECTIONS',
                      style: AppTypography.headline(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (recentScansState.scans.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          AppMotion.tapHaptic();
                          context.goToHistory();
                        },
                        child: Text(
                          'SEE ALL',
                          style: AppTypography.headline(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s),

              // Grouped Inset List of Recent Scans (State-driven)
              _buildRecentScansContent(context, ref, recentScansState),
              const SizedBox(height: AppSpacing.l),

              // Quick Entry: Offline First-Aid Card
              const FirstAidEntryCard(),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),

      // Ergonomic Primary "Scan Fish" CTA in Bottom 40% Thumb Zone
      bottomNavigationBar: const HomeScanBottomBar(),
    );
  }

  Widget _buildRecentScansContent(
    BuildContext context,
    WidgetRef ref,
    RecentScansState state,
  ) {
    if (state.status == RecentScansStatus.error) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderCard,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              state.errorMessage ?? 'Unable to load history',
              style: AppTypography.subheadline(color: AppColors.verdictAvoid),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton(
              onPressed: () =>
                  ref.read(recentScansViewModelProvider.notifier).loadScans(),
              child: const Text('Tap to Retry'),
            ),
          ],
        ),
      );
    }

    if (state.scans.isEmpty && !state.isLoading) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderCard,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'No inspections yet. Scan your first fish below!',
            style: AppTypography.footnote(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return RecentScansCard(items: state.scans);
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.borderButton,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.caption1(color: AppColors.textPrimary)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                style: AppTypography.caption2(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
