import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/theme.dart';
import 'core/routing/routing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final router = AppRouter.createRouter();
  runApp(FishGuardApp(router: router));
}

/// Root Application Widget configured with Riverpod ProviderScope and GoRouter.
class FishGuardApp extends StatelessWidget {
  final GoRouter? router;

  const FishGuardApp({
    super.key,
    this.router,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'FishGuard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router ?? AppRouter.createRouter(),
      ),
    );
  }
}
