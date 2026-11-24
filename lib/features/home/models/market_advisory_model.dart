import 'package:material_ui/material_ui.dart';

/// Contextual wet-market conditions calculated from time of day.
class MarketAdvisoryModel {
  final String sessionTitle;
  final String temperatureLabel;
  final String weatherIconName;
  final IconData icon;
  final String badgeText;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final List<String> tips;

  const MarketAdvisoryModel({
    required this.sessionTitle,
    required this.temperatureLabel,
    required this.weatherIconName,
    required this.icon,
    required this.badgeText,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.tips,
  });

  /// Factory resolving current market conditions based on [currentTime].
  factory MarketAdvisoryModel.fromTime([DateTime? currentTime]) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 4 && hour < 10) {
      return const MarketAdvisoryModel(
        sessionTitle: 'Morning Market Catch',
        temperatureLabel: '27°C • Fresh Arrival',
        weatherIconName: 'wb_sunny',
        icon: Icons.wb_sunny_rounded,
        badgeText: 'PEAK FRESHNESS',
        accentColor: Color(0xFF007A87),
        backgroundColor: Color(0xFFE6F4F6),
        borderColor: Color(0xFFB2DFDB),
        tips: [
          'Fresh shipments on display. Verify clear corneas and vibrant red gills before ice begins melting.',
          'Early morning catches have the lowest natural histamine levels.',
          'Ask vendors for fish stored at the bottom of the fresh ice pile.',
        ],
      );
    } else if (hour >= 10 && hour < 15) {
      return const MarketAdvisoryModel(
        sessionTitle: 'Midday Temperature Advisory',
        temperatureLabel: '33°C • Ambient Heat',
        weatherIconName: 'thermostat',
        icon: Icons.thermostat_rounded,
        badgeText: 'HEAT ADVISORY',
        accentColor: Color(0xFFB45309),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
        tips: [
          'Ambient heat accelerates spoilage. Choose only specimens packed deep in crushed ice.',
          'Scombroid fish (Tongkol, Kembung) left off-ice past 90 min build heat-stable histamine.',
          'Always inspect gill firmness; avoid fish with warm or watery surface texture.',
        ],
      );
    } else if (hour >= 15 && hour < 20) {
      return const MarketAdvisoryModel(
        sessionTitle: 'Late Market Session',
        temperatureLabel: '29°C • Humid Afternoon',
        weatherIconName: 'nights_stay',
        icon: Icons.wb_twilight_rounded,
        badgeText: 'CAREFUL INSPECTION',
        accentColor: Color(0xFF4338CA),
        backgroundColor: Color(0xFFEEF2FF),
        borderColor: Color(0xFFC7D2FE),
        tips: [
          'Late afternoon stalls: check flesh springiness with a clean finger press before buying.',
          'Histamine is completely invisible and odorless in early stages: prioritize cold ice.',
          'Cook purchased fish today or freeze immediately below 0°C.',
        ],
      );
    } else {
      return const MarketAdvisoryModel(
        sessionTitle: 'Catch Handling & Storage',
        temperatureLabel: '25°C • Night Storage',
        weatherIconName: 'bedtime',
        icon: Icons.shield_outlined,
        badgeText: 'STORAGE TIP',
        accentColor: Color(0xFF0F766E),
        backgroundColor: Color(0xFFF0FDFA),
        borderColor: Color(0xFF99F6E4),
        tips: [
          'Refrigerate seafood below 4°C immediately upon arrival at home.',
          'Separate viscera and head promptly to prevent bacterial migration into meat.',
          'Cooking or boiling does NOT neutralize heat-stable histamine or ciguatoxins.',
        ],
      );
    }
  }
}
