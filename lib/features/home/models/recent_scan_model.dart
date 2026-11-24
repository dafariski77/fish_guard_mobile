import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/scan_result_model.dart';

/// Immutable model representing a past fish inspection record.
/// Fully serializable to and from JSON for persistent disk storage.
class RecentScanModel {
  final String species;
  final String time;
  final int freshnessScore;
  final String verdict;
  final Color verdictColor;
  final Color verdictBg;
  final bool isCaution;
  final bool isAvoid;
  final ScanResultModel? scanResult;
  final DateTime? timestamp;

  const RecentScanModel({
    required this.species,
    required this.time,
    required this.freshnessScore,
    required this.verdict,
    required this.verdictColor,
    required this.verdictBg,
    required this.isCaution,
    this.isAvoid = false,
    this.scanResult,
    this.timestamp,
  });

  /// Factory adapter creating a RecentScanModel directly from a Section 5 ScanResultModel.
  factory RecentScanModel.fromScanResult(ScanResultModel result) {
    final isSafe = result.verdict.isSafe;
    final isCaution = result.verdict.isCaution;
    final isAvoid = result.verdict.isAvoid;

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
      isAvoid: isAvoid,
      scanResult: result,
      timestamp: result.timestamp,
    );
  }

  /// Converts this model into a JSON-encodable map for persistence.
  Map<String, dynamic> toJson() => {
    'species': species,
    'time': time,
    'freshnessScore': freshnessScore,
    'verdict': verdict,
    'isCaution': isCaution,
    'isAvoid': isAvoid,
    'timestamp': (timestamp ?? scanResult?.timestamp)?.toIso8601String(),
    if (scanResult != null) 'scanResult': scanResult!.toJson(),
  };

  /// Constructs a [RecentScanModel] from a decoded JSON map.
  factory RecentScanModel.fromJson(Map<String, dynamic> json) {
    final isCaution = json['isCaution'] as bool? ?? false;
    final isAvoid = json['isAvoid'] as bool? ?? false;
    final isSafe = !isCaution && !isAvoid;

    final parsedTimestamp = json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'] as String)
        : null;

    ScanResultModel? parsedScanResult;
    if (json['scanResult'] is Map<String, dynamic>) {
      try {
        parsedScanResult = ScanResultModel.fromJson(
          Map<String, dynamic>.from(json['scanResult'] as Map),
        );
      } catch (_) {}
    }

    // Compute relative human-friendly time when timestamp is available
    final rawTime = json['time'] as String? ?? 'Just now';
    final effectiveTime = parsedTimestamp != null
        ? _formatRelativeTime(parsedTimestamp)
        : rawTime;

    return RecentScanModel(
      species: json['species'] as String? ?? 'Unknown Fish',
      time: effectiveTime,
      freshnessScore: (json['freshnessScore'] as num?)?.toInt() ?? 0,
      verdict: json['verdict'] as String? ??
          (isSafe ? 'SAFE' : (isCaution ? 'CAUTION' : 'AVOID')),
      verdictColor: isSafe
          ? AppColors.verdictSafe
          : (isCaution ? AppColors.verdictCaution : AppColors.verdictAvoid),
      verdictBg: isSafe
          ? AppColors.verdictSafeBg
          : (isCaution ? AppColors.verdictCautionBg : AppColors.verdictAvoidBg),
      isCaution: isCaution,
      isAvoid: isAvoid,
      scanResult: parsedScanResult,
      timestamp: parsedTimestamp ?? parsedScanResult?.timestamp,
    );
  }

  static String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative || difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
