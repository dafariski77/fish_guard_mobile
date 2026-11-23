import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/scan_result_model.dart';

/// Immutable model representing a past fish inspection record.
class RecentScanModel {
  final String species;
  final String time;
  final int freshnessScore;
  final String verdict;
  final Color verdictColor;
  final Color verdictBg;
  final bool isCaution;
  final ScanResultModel? scanResult;

  const RecentScanModel({
    required this.species,
    required this.time,
    required this.freshnessScore,
    required this.verdict,
    required this.verdictColor,
    required this.verdictBg,
    required this.isCaution,
    this.scanResult,
  });

  /// Factory adapter creating a RecentScanModel directly from a Section 5 ScanResultModel.
  factory RecentScanModel.fromScanResult(ScanResultModel result) {
    final isSafe = result.verdict.isSafe;
    final isCaution = result.verdict.isCaution;

    return RecentScanModel(
      species: result.species.displayName,
      time: 'Just now',
      freshnessScore: result.vision.combinedFreshnessScore.round(),
      verdict: isSafe ? 'SAFE' : (isCaution ? 'CAUTION' : 'AVOID'),
      verdictColor: isSafe
          ? AppColors.verdictSafe
          : (isCaution ? AppColors.verdictCaution : AppColors.verdictAvoid),
      verdictBg: isSafe
          ? AppColors.verdictSafeBg
          : (isCaution ? AppColors.verdictCautionBg : AppColors.verdictAvoidBg),
      isCaution: isCaution,
      scanResult: result,
    );
  }
}
