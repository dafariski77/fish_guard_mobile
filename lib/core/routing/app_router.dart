import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'route_arguments.dart';
import '../theme/theme.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/scanner/screens/scanner_viewfinder_screen.dart';
import '../../features/verdict/screens/verdict_screen.dart';
import '../../features/first_aid/screens/first_aid_screen.dart';
import '../../features/history/screens/history_screen.dart';

/// Central Declarative Router for FishGuard built with GoRouter.
/// Engineered for scalability, deep linking, and future MVVM state injection.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  /// Creates and configures the GoRouter instance.
  /// Can accept an initial route or auth/state stream for MVVM redirect guards.
  static GoRouter createRouter({String initialLocation = AppRoutes.onboarding}) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation,
      debugLogDiagnostics: false,
      routes: [
        // Branded Splash Screen
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          pageBuilder: (context, state) => _buildPageWithFadeTransition(
            state: state,
            child: const SplashScreen(),
          ),
        ),

        // Onboarding Screen
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboardingName,
          pageBuilder: (context, state) => _buildPageWithFadeTransition(
            state: state,
            child: const OnboardingScreen(),
          ),
        ),

        // Home Dashboard
        GoRoute(
          path: AppRoutes.home,
          name: AppRoutes.homeName,
          pageBuilder: (context, state) => _buildPageWithFadeTransition(
            state: state,
            child: const HomeScreen(),
          ),
        ),

        // 2-Step Viewfinder Camera Scanner
        GoRoute(
          path: AppRoutes.scanner,
          name: AppRoutes.scannerName,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            state: state,
            child: const ScannerViewfinderScreen(),
          ),
        ),

        // Safety Verdict & Explainability Screen
        GoRoute(
          path: AppRoutes.verdict,
          name: AppRoutes.verdictName,
          pageBuilder: (context, state) {
            final args = state.extra is VerdictRouteArgs
                ? state.extra as VerdictRouteArgs
                : VerdictRouteArgs.defaultSafe();

            return _buildPageWithSlideTransition(
              state: state,
              child: VerdictScreen(
                speciesName: args.speciesName,
                score: args.score,
                isCaution: args.isCaution,
                isAvoid: args.isAvoid,
                smell: args.smell,
                texture: args.texture,
                storage: args.storage,
                scanResult: args.scanResult,
              ),
            );
          },
        ),

        // Offline First-Aid & ER Poisoning Guide
        GoRoute(
          path: AppRoutes.firstAid,
          name: AppRoutes.firstAidName,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            state: state,
            child: const FirstAidScreen(),
          ),
        ),

        // Full Inspection History
        GoRoute(
          path: AppRoutes.history,
          name: AppRoutes.historyName,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            state: state,
            child: const HistoryScreen(),
          ),
        ),
      ],

      // 404 / Route Error Fallback
      errorPageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: _RouteErrorScreen(error: state.error),
      ),
    );
  }

  /// Apple-style horizontal slide page transition
  static CustomTransitionPage<void> _buildPageWithSlideTransition({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.spring,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppMotion.curveMicro,
        ));

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  /// Apple-style smooth crossfade transition
  static CustomTransitionPage<void> _buildPageWithFadeTransition({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

/// Fallback screen for unmapped deep links or route errors.
class _RouteErrorScreen extends StatelessWidget {
  final Exception? error;

  const _RouteErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.explore_off_rounded, size: 64, color: AppColors.verdictCaution),
                const SizedBox(height: AppSpacing.l),
                Text('Page Not Found', style: AppTypography.title2()),
                const SizedBox(height: AppSpacing.s),
                Text(
                  error?.toString() ?? 'The requested safety destination does not exist.',
                  style: AppTypography.footnote(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton(
                  onPressed: () => context.goNamed(AppRoutes.homeName),
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ergonomic navigation extensions on BuildContext.
/// Enforces separation of concerns so ViewModels and Views don't hardcode route names.
extension AppNavigationExtension on BuildContext {
  void goToSplash() => goNamed(AppRoutes.splashName);
  void goToHome() => goNamed(AppRoutes.homeName);
  void goToOnboarding() => goNamed(AppRoutes.onboardingName);
  void goToScanner() => pushNamed(AppRoutes.scannerName);
  void goToVerdict(VerdictRouteArgs args) => pushNamed(AppRoutes.verdictName, extra: args);
  void goToFirstAid() => pushNamed(AppRoutes.firstAidName);
  void goToHistory() => pushNamed(AppRoutes.historyName);
}
