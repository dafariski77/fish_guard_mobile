import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../models/sensory_option_item.dart';

/// Single Responsibility widget: Renders a titled question group with selectable chips.
/// Open/Closed: Options and callbacks are passed dynamically.
class SensoryQuestionGroup extends StatelessWidget {
  final String title;
  final List<SensoryOptionItem> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const SensoryQuestionGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headline(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: options.map((opt) {
              final isSelected = opt.id == selectedId;
              return ChoiceChip(
                label: Text(opt.label),
                selected: isSelected,
                onSelected: (_) {
                  AppMotion.spring;
                  onSelected(opt.id);
                },
                selectedColor: AppColors.primaryLight,
                backgroundColor: AppColors.groupedBackground,
                pressElevation: 0,
                labelStyle: isSelected
                    ? AppTypography.subheadlineSemiBold(
                        color: AppColors.primary,
                      )
                    : AppTypography.subheadline(color: AppColors.textPrimary),
                shape: AppRadius.buttonShape(
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.0,
                  ),
                ),
                checkmarkColor: AppColors.primary,
                showCheckmark: true,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
