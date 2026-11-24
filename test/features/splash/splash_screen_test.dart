import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fish_guard_mobile/core/routing/routing.dart';
import 'package:fish_guard_mobile/features/splash/screens/splash_screen.dart';
import 'package:fish_guard_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:fish_guard_mobile/features/home/screens/home_screen.dart';
import 'package:fish_guard_mobile/features/onboarding/repositories/onboarding_repository.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  bool completed;
  _FakeOnboardingRepository({this.completed = false});

  @override
  Future<bool> hasCompletedOnboarding() async => completed;

  @override
  Future<void> setCompletedOnboarding() async => completed = true;

  @override
  Future<void> resetOnboarding() async => completed = false;
}

void main() {
  group('SplashScreen UI & Auto-Navigation Tests', () {
    testWidgets('Renders branded visual elements and offline badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingRepositoryProvider.overrideWithValue(
              _FakeOnboardingRepository(completed: false),
            ),
          ],
          child: MaterialApp(
            home: const SplashScreen(
              autoNavigate: false,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('FishGuard'), findsOneWidget);
      expect(find.text('Smart Seafood Safety'), findsOneWidget);
      expect(find.text('100% Offline Edge ML'), findsOneWidget);
      expect(find.text('On-Device LiteRT Inference'), findsOneWidget);
    });

    testWidgets('Auto-dispatches to Onboarding if first-time user',
        (WidgetTester tester) async {
      final fakeRepo = _FakeOnboardingRepository(completed: false);

      final router = AppRouter.createRouter(initialLocation: AppRoutes.splash);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Pump through the short test delay
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Instant Wet-Market Safety'), findsOneWidget);
    });

    testWidgets('Auto-dispatches to Home if returning user with completed onboarding',
        (WidgetTester tester) async {
      final fakeRepo = _FakeOnboardingRepository(completed: true);

      final router = AppRouter.createRouter(initialLocation: AppRoutes.splash);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Pump through the short test delay
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('RECENT INSPECTIONS'), findsOneWidget);
    });
  });
}
