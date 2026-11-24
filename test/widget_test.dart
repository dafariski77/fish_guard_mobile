import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fish_guard_mobile/main.dart';

void main() {
  testWidgets('FishGuard End-to-End UI Flow Smoke Test', (WidgetTester tester) async {
    // 1. Build app and verify Onboarding Screen mounts
    await tester.pumpWidget(const FishGuardApp());
    await tester.pumpAndSettle();

    expect(find.text('Instant Wet-Market Safety'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);

    // 2. Tap Skip to navigate directly to HomeScreen
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    // 3. Verify HomeScreen elements
    expect(find.text('FishGuard'), findsOneWidget);
    expect(find.text('Smart Seafood Safety'), findsOneWidget);
    expect(find.text('Scan Fish (2-Step AI)'), findsOneWidget);
    expect(find.text('RECENT INSPECTIONS'), findsOneWidget);

    // Scroll down to First Aid Entry
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Offline Fish Poisoning Guide'), findsOneWidget);
  });
}
