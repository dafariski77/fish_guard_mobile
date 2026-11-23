import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/models/scan_result_model.dart';
import '../../../core/models/sensory_input.dart';
import '../models/sensory_option_item.dart';
import '../widgets/sensory_question_group.dart';
import '../viewmodels/scanner_viewmodel.dart';

/// 10-Second Sensory Check Bottom Sheet (v3.0 Apple HIG Modal Sheet).
/// Connects user sensory responses to the edge Hybrid Risk Fusion Engine via Riverpod.
class SensoryCheckBottomSheet extends ConsumerStatefulWidget {
  final String speciesName;

  const SensoryCheckBottomSheet({
    super.key,
    this.speciesName = 'Tongkol (Bullet Tuna)',
  });

  static Future<ScanResultModel?> show(
    BuildContext context, {
    String speciesName = 'Tongkol (Bullet Tuna)',
  }) {
    return showModalBottomSheet<ScanResultModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SensoryCheckBottomSheet(speciesName: speciesName),
    );
  }

  @override
  ConsumerState<SensoryCheckBottomSheet> createState() =>
      _SensoryCheckBottomSheetState();
}

class _SensoryCheckBottomSheetState
    extends ConsumerState<SensoryCheckBottomSheet> {
  String _selectedSmell = 'fresh_sea';
  String _selectedTexture = 'bounces_back';
  String _selectedStorage = 'packed_in_ice';

  static const List<SensoryOptionItem> _smellOptions = [
    SensoryOptionItem(id: 'fresh_sea', label: 'Fresh Ocean / Brine'),
    SensoryOptionItem(id: 'sour_ammonia', label: 'Sour / Ammonia Odor'),
    SensoryOptionItem(id: 'odorless', label: 'No Scent / Odorless'),
  ];

  static const List<SensoryOptionItem> _textureOptions = [
    SensoryOptionItem(id: 'bounces_back', label: 'Firm & Bounces Back'),
    SensoryOptionItem(id: 'mushy', label: 'Soft / Indented Mush'),
    SensoryOptionItem(id: 'unnaturally_stiff', label: 'Unnaturally Stiff / Hard'),
  ];

  static const List<SensoryOptionItem> _storageOptions = [
    SensoryOptionItem(id: 'packed_in_ice', label: 'Submerged in Clean Ice'),
    SensoryOptionItem(id: 'no_ice_room_temp', label: 'Off-Ice (Room Temp)'),
  ];

  Future<void> _onSeeResult({bool skipped = false}) async {
    AppMotion.lockOnHaptic();

    final sensory = skipped
        ? SensoryInput.skipped()
        : SensoryInput(
            smell: _selectedSmell,
            texture: _selectedTexture,
            storage: _selectedStorage,
          );

    final vm = ref.read(scannerViewModelProvider.notifier);
    final result = await vm.submitSensoryAndCalculateVerdict(sensory);

    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderSheet,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '10s Sensory Check',
                            style: AppTypography.title1(color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppRadius.borderFull,
                          ),
                          child: Text(
                            widget.speciesName,
                            style: AppTypography.caption2(color: AppColors.primary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Select what you notice at the stall (3 taps):',
                      style: AppTypography.footnote(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Divider(height: 0.5),

              // Question 1: Smell
              SensoryQuestionGroup(
                title: '1. Fish Smell',
                options: _smellOptions,
                selectedId: _selectedSmell,
                onSelected: (val) => setState(() => _selectedSmell = val),
              ),

              // Question 2: Texture
              SensoryQuestionGroup(
                title: '2. Flesh Bounce-Back',
                options: _textureOptions,
                selectedId: _selectedTexture,
                onSelected: (val) => setState(() => _selectedTexture = val),
              ),

              // Question 3: Storage
              SensoryQuestionGroup(
                title: '3. Vendor Storage',
                options: _storageOptions,
                selectedId: _selectedStorage,
                onSelected: (val) => setState(() => _selectedStorage = val),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Primary Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: SizedBox(
                  height: AppSpacing.primaryButtonHeight,
                  child: ElevatedButton(
                    onPressed: () => _onSeeResult(skipped: false),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Calculate Safety Verdict',
                      style: AppTypography.headline(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s),

              // Skip Option
              Center(
                child: TextButton(
                  onPressed: () => _onSeeResult(skipped: true),
                  child: Text(
                    'Skip (Visual Grade Only)',
                    style: AppTypography.subheadline(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
