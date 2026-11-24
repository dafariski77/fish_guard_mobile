import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contract for persisting onboarding completion state (DIP).
abstract class OnboardingRepository {
  Future<bool> hasCompletedOnboarding();
  Future<void> setCompletedOnboarding();
  Future<void> resetOnboarding();
}

/// SharedPreferences implementation of [OnboardingRepository].
class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  static const _key = 'has_completed_onboarding';
  final SharedPreferences? prefs;

  SharedPreferencesOnboardingRepository({this.prefs});

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> setCompletedOnboarding() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_key, true);
  }

  @override
  Future<void> resetOnboarding() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }
}

/// Riverpod provider for [OnboardingRepository].
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SharedPreferencesOnboardingRepository();
});

/// Riverpod state notifier to track onboarding state reactively.
final onboardingCompletedProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repo = ref.watch(onboardingRepositoryProvider);
    return repo.hasCompletedOnboarding();
  }

  Future<void> complete() async {
    final repo = ref.read(onboardingRepositoryProvider);
    await repo.setCompletedOnboarding();
    state = const AsyncValue.data(true);
  }

  Future<void> reset() async {
    final repo = ref.read(onboardingRepositoryProvider);
    await repo.resetOnboarding();
    state = const AsyncValue.data(false);
  }
}
