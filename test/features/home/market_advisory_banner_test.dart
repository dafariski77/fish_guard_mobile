import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fish_guard_mobile/features/home/widgets/market_advisory_banner.dart';

void main() {
  group('MarketAdvisoryBanner Dynamic Context & Tip Cycling Tests', () {
    testWidgets('Renders Morning Market Catch session in early morning', (tester) async {
      final morningTime = DateTime(2026, 11, 24, 7, 30);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarketAdvisoryBanner(mockTime: morningTime),
          ),
        ),
      );

      expect(find.text('Morning Market Catch'), findsOneWidget);
      expect(find.text('27°C • Fresh Arrival'), findsOneWidget);
      expect(find.text('PEAK FRESHNESS'), findsOneWidget);
    });

    testWidgets('Renders Midday Temperature Advisory during peak heat', (tester) async {
      final middayTime = DateTime(2026, 11, 24, 12, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarketAdvisoryBanner(mockTime: middayTime),
          ),
        ),
      );

      expect(find.text('Midday Temperature Advisory'), findsOneWidget);
      expect(find.text('33°C • Ambient Heat'), findsOneWidget);
      expect(find.text('HEAT ADVISORY'), findsOneWidget);
    });

    testWidgets('Tapping cycles to next tip', (tester) async {
      final morningTime = DateTime(2026, 11, 24, 8, 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarketAdvisoryBanner(mockTime: morningTime),
          ),
        ),
      );

      expect(find.textContaining('Fresh shipments on display'), findsOneWidget);

      // Tap banner to cycle tip
      await tester.tap(find.byType(MarketAdvisoryBanner));
      await tester.pumpAndSettle();

      expect(find.textContaining('lowest natural histamine levels'), findsOneWidget);
    });
  });
}
