import '../models/recent_scan_model.dart';

enum RecentScansStatus { initial, loading, loaded, error }

/// Immutable UI State for the Home Dashboard Scans section.
class RecentScansState {
  final RecentScansStatus status;
  final List<RecentScanModel> scans;
  final String? errorMessage;

  const RecentScansState({
    this.status = RecentScansStatus.initial,
    this.scans = const [],
    this.errorMessage,
  });

  /// Factory helper for initial state
  factory RecentScansState.initial() => const RecentScansState();

  /// Whether data is currently loading
  bool get isLoading => status == RecentScansStatus.loading;

  /// Whether there are any scans available
  bool get hasScans => scans.isNotEmpty;

  /// Check if any recent scan has caution/warning requiring alert prominence
  bool get hasRecentCaution => scans.any((scan) => scan.isCaution);

  RecentScansState copyWith({
    RecentScansStatus? status,
    List<RecentScanModel>? scans,
    String? errorMessage,
  }) {
    return RecentScansState(
      status: status ?? this.status,
      scans: scans ?? this.scans,
      errorMessage: errorMessage,
    );
  }
}
