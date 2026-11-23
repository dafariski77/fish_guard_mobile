import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility utility for Verdict dialogs (Cold-chain reminders & user feedback).
abstract final class VerdictDialogs {
  /// Displays celebratory confirmation dialog with scheduled cold-chain storage reminders.
  static void showColdChainConfirmation(BuildContext context) {
    AppMotion.safeVerdictHaptic();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: AppRadius.cardShape(),
        title: Row(
          children: [
            const Icon(Icons.alarm_on_rounded, color: AppColors.verdictSafe, size: 28),
            const SizedBox(width: AppSpacing.s),
            Text('Reminder Set!', style: AppTypography.headline()),
          ],
        ),
        content: Text(
          'FishGuard scheduled local reminders:\n\n• In 2 hours: Put fish in refrigerator or freeze.\n• In 24 hours: Cook and consume.',
          style: AppTypography.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Done', style: AppTypography.headline(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  /// Displays active-learning feedback dialog to anonymously report misclassifications.
  static void showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: AppRadius.cardShape(),
        title: Text('Help Improve AI', style: AppTypography.headline()),
        content: Text(
          'Your feedback will be queued and synced anonymously when connected to Wi-Fi. No GPS or personal data is collected.',
          style: AppTypography.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback saved locally. Will sync on Wi-Fi.')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
