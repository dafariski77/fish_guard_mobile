import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_guard_mobile/features/onboarding/repositories/onboarding_repository.dart';

void main() {
  group('OnboardingRepository & Riverpod State Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state is false when user has not completed onboarding', () async {
      final repo = SharedPreferencesOnboardingRepository();
      expect(await repo.hasCompletedOnboarding(), isFalse);
    });

    test('Persists true when setCompletedOnboarding is called', () async {
      final repo = SharedPreferencesOnboardingRepository();
      await repo.setCompletedOnboarding();
      expect(await repo.hasCompletedOnboarding(), isTrue);
    });

    test('Can reset onboarding back to false', () async {
      final repo = SharedPreferencesOnboardingRepository();
      await repo.setCompletedOnboarding();
      expect(await repo.hasCompletedOnboarding(), isTrue);

      await repo.resetOnboarding();
      expect(await repo.hasCompletedOnboarding(), isFalse);
    });

    test('OnboardingNotifier updates state reactively', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial read
      expect(await container.read(onboardingCompletedProvider.future), isFalse);

      // Complete onboarding
      await container.read(onboardingCompletedProvider.notifier).complete();
      expect(container.read(onboardingCompletedProvider).value, isTrue);

      // Verify persistence via repository
      final repo = container.read(onboardingRepositoryProvider);
      expect(await repo.hasCompletedOnboarding(), isTrue);
    });
  });
}
