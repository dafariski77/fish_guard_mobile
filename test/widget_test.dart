import 'package:flutter_test/flutter_test.dart';
import 'package:fish_guard_mobile/main.dart';

void main() {
  testWidgets('FishGuard End-to-End UI Flow Smoke Test', (WidgetTester tester) async {
    // 1. Build app and verify Onboarding Screen mounts
    await tester.pumpWidget(const FishGuardApp());
    await tester.pumpAndSettle();

    expect(find.text('Instant Wet-Market Safety'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // 2. Tap Skip to navigate directly to HomeScreen
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // 3. Verify HomeScreen elements
    expect(find.text('FishGuard'), findsOneWidget);
    expect(find.text('100% Offline'), findsOneWidget);
    expect(find.text('Scan Fish (2-Step AI)'), findsOneWidget);
    expect(find.text('Recent Inspections'), findsOneWidget);
    expect(find.text('Offline Fish Poisoning Guide'), findsOneWidget);
  });
}
