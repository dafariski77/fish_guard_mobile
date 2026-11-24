import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';
import '../models/onboarding_item.dart';
import '../widgets/onboarding_vector_illustrations.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../widgets/onboarding_page_content.dart';
import '../repositories/onboarding_repository.dart';

/// 3-Slide Onboarding Walkthrough for FishGuard.
/// Orchestrates the page controller and bottom thumb-zone actions (SRP).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Instant Wet-Market Safety',
      description: 'Scan fish eyes and gills in seconds. Get objective biological freshness grading at the market stall before paying.',
      illustration: OnboardingIllustration1(),
    ),
    OnboardingItem(
      title: 'Works 100% Offline',
      description: 'Zero cellular signal or Wi-Fi needed. High-speed LiteRT models run entirely on your smartphone hardware.',
      illustration: OnboardingIllustration2(),
    ),
    OnboardingItem(
      title: 'Detect Invisible Hazards',
      description: 'Fuses Computer Vision with a 10s sensory check to catch heat-stable histamine, ciguatoxin, and formalin.',
      illustration: OnboardingIllustration3(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    AppMotion.tapHaptic();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppMotion.spring,
        curve: AppMotion.curveMicro,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    AppMotion.lockOnHaptic();
    // Persist onboarding completion so returning launches go directly to home
    ref.read(onboardingCompletedProvider.notifier).complete();
    context.goToHome();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actionsPadding: EdgeInsets.only(right: AppSpacing.l),
        elevation: 0,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'SKIP',
                style: AppTypography.subheadline(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Page Content Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  AppMotion.selectionHaptic();
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageContent(item: _pages[index]);
                },
              ),
            ),

            // Bottom Thumb Zone (Indicators + CTA Button)
            Padding(
              padding: AppSpacing.bottomThumbZone,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OnboardingDotIndicator(
                    totalCount: _pages.length,
                    currentIndex: _currentPage,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.primaryButtonHeight,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Text(
                        isLastPage ? 'Enable Camera & Get Started' : 'Continue',
                        style: AppTypography.headline(
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                  ),

                  if (isLastPage) ...[
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'AI Screening Assistant • Not a Certified Laboratory Test',
                      style: AppTypography.caption2(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
