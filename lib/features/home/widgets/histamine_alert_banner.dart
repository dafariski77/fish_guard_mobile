import 'package:material_ui/material_ui.dart';
import 'market_advisory_banner.dart';

/// Dynamic, non-alarmist market temperature & freshness advisory reminder banner.
/// Replaces the static danger banner with helpful, time-sensitive advice.
class HistamineAlertBanner extends StatelessWidget {
  const HistamineAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const MarketAdvisoryBanner();
  }
}
