import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';
import '../../home/models/recent_scan_model.dart';
import '../../home/viewmodels/recent_scans_viewmodel.dart';

enum HistoryFilter { all, safe, caution, avoid }

/// Full Inspection History Screen with search, status filtering,
/// deletion, and seamless navigation to detailed verdicts.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  HistoryFilter _activeFilter = HistoryFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecentScanModel> _filterScans(List<RecentScanModel> scans) {
    return scans.where((scan) {
      // 1. Text Search Filter
      final matchesQuery = _searchQuery.isEmpty ||
          scan.species.toLowerCase().contains(_searchQuery) ||
          scan.verdict.toLowerCase().contains(_searchQuery);

      if (!matchesQuery) return false;

      // 2. Chip Grade Filter
      switch (_activeFilter) {
        case HistoryFilter.all:
          return true;
        case HistoryFilter.safe:
          return !scan.isCaution && !scan.isAvoid;
        case HistoryFilter.caution:
          return scan.isCaution;
        case HistoryFilter.avoid:
          return scan.isAvoid;
      }
    }).toList();
  }

  void _confirmClearAll() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Inspection History'),
        content: const Text(
          'Are you sure you want to delete all saved scan logs? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final state = ref.read(recentScansViewModelProvider);
              final notifier = ref.read(recentScansViewModelProvider.notifier);
              for (int i = state.scans.length - 1; i >= 0; i--) {
                await notifier.removeScan(i);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inspection history cleared')),
                );
              }
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.verdictAvoid),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentScansState = ref.watch(recentScansViewModelProvider);
    final filteredScans = _filterScans(recentScansState.scans);

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        backgroundColor: AppColors.groupedBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Inspection History',
          style: AppTypography.title2(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          if (recentScansState.scans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textSecondary),
              tooltip: 'Clear History',
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.s,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by species (e.g. Tongkol, Bandeng)...',
                  hintStyle: AppTypography.subheadline(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderCard,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderCard,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderCard,
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Row(
                children: [
                  _buildFilterChip('All (${recentScansState.scans.length})', HistoryFilter.all),
                  const SizedBox(width: AppSpacing.s),
                  _buildFilterChip('Safe', HistoryFilter.safe),
                  const SizedBox(width: AppSpacing.s),
                  _buildFilterChip('Caution', HistoryFilter.caution),
                  const SizedBox(width: AppSpacing.s),
                  _buildFilterChip('Avoid', HistoryFilter.avoid),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Scans List or Empty State
            Expanded(
              child: filteredScans.isEmpty
                  ? _buildEmptyState(recentScansState.scans.isEmpty)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                        vertical: AppSpacing.s,
                      ),
                      itemCount: filteredScans.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.m),
                      itemBuilder: (context, index) {
                        final item = filteredScans[index];
                        return _buildHistoryCard(context, item, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, HistoryFilter filter) {
    final isSelected = _activeFilter == filter;
    return ChoiceChip(
      label: Text(label),
      labelStyle: AppTypography.caption1(
        color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
      ).copyWith(fontWeight: FontWeight.w600),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.card,
      elevation: isSelected ? 1 : 0,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      onSelected: (selected) {
        if (selected) {
          AppMotion.selectionHaptic();
          setState(() => _activeFilter = filter);
        }
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, RecentScanModel item, int index) {
    return Dismissible(
      key: Key('history_item_${item.species}_${item.time}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.verdictAvoid,
          borderRadius: AppRadius.borderCard,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(recentScansViewModelProvider.notifier).removeScan(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed ${item.species} scan record')),
        );
      },
      child: InkWell(
        onTap: () {
          AppMotion.selectionHaptic();
          if (item.scanResult != null) {
            context.goToVerdict(VerdictRouteArgs.fromScanResult(item.scanResult!));
          } else {
            context.goToVerdict(
              VerdictRouteArgs(
                speciesName: item.species,
                score: item.freshnessScore,
                isCaution: item.isCaution,
                isAvoid: item.isAvoid,
              ),
            );
          }
        },
        borderRadius: AppRadius.borderCard,
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.borderCard,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.borderButton,
                    ),
                    child: const Icon(
                      Icons.set_meal_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.species,
                          style: AppTypography.headline(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          item.time,
                          style: AppTypography.footnote(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: item.verdictBg,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      '${item.freshnessScore}% ${item.verdict}',
                      style: AppTypography.caption1(color: item.verdictColor)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              if (item.scanResult?.verdict.reasons.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacing.s),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: AppSpacing.s),
                Text(
                  item.scanResult!.verdict.reasons.first,
                  style: AppTypography.footnote(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isCompletelyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.cardSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                isCompletelyEmpty
                    ? Icons.history_rounded
                    : Icons.search_off_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              isCompletelyEmpty
                  ? 'No Saved Inspections'
                  : 'No Matching Scans',
              style: AppTypography.title2(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isCompletelyEmpty
                  ? 'Your wet-market fish scans and safety verdicts will appear here.'
                  : 'Try checking your search spelling or changing the filter chip.',
              style: AppTypography.footnote(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
