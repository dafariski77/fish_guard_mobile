import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';
import '../../../core/models/scan_result_model.dart';
import '../widgets/verdict_hero_card.dart';
import '../widgets/verdict_species_card.dart';
import '../widgets/verdict_explainability_card.dart';
import '../widgets/verdict_dialogs.dart';

/// Safety Verdict & Visual Explainability Screen.
/// Refactored to adhere to SOLID: delegates hero banner, species identification,
/// evidence details, and dialogs to focused components.
class VerdictScreen extends StatelessWidget {
  final String speciesName;
  final int score;
  final bool isCaution;
  final bool isAvoid;
  final String smell;
  final String texture;
  final String storage;
  final ScanResultModel? scanResult;

  const VerdictScreen({
    super.key,
    required this.speciesName,
    required this.score,
    this.isCaution = false,
    this.isAvoid = false,
    this.smell = 'fresh_sea',
    this.texture = 'bounces_back',
    this.storage = 'packed_in_ice',
    this.scanResult,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIsCaution = scanResult?.verdict.isCaution ?? isCaution;
    final effectiveIsAvoid = scanResult?.verdict.isAvoid ?? isAvoid;
    final isSafe = !effectiveIsCaution && !effectiveIsAvoid;
    final effectiveScore = scanResult != null
        ? scanResult!.vision.combinedFreshnessScore.round()
        : score;
    final effectiveSpeciesName =
        scanResult?.species.displayName ?? speciesName;
    final confidence = scanResult != null
        ? (scanResult!.species.confidence * 100).round()
        : null;
    final riskTier = (scanResult?.species.intrinsicRisk ??
            (effectiveIsCaution ? 'HIGH_HISTAMINE' : 'LOW_RISK'))
        .replaceAll('_', ' ');

    final Color verdictColor = isSafe
        ? AppColors.verdictSafe
        : (effectiveIsCaution
            ? AppColors.verdictCaution
            : AppColors.verdictAvoid);

    final Color verdictBg = isSafe
        ? AppColors.verdictSafeBg
        : (effectiveIsCaution
            ? AppColors.verdictCautionBg
            : AppColors.verdictAvoidBg);

    final Color verdictBorder = isSafe
        ? AppColors.verdictSafeBorder
        : (effectiveIsCaution
            ? AppColors.verdictCautionBorder
            : AppColors.verdictAvoidBorder);

    final String verdictTitle = isSafe
        ? 'Safe to Buy'
        : (effectiveIsCaution
            ? 'Caution Advised'
            : 'Do Not Buy (High Risk)');

    final IconData verdictIcon = isSafe
        ? Icons.check_circle_rounded
        : (effectiveIsCaution ? Icons.warning_rounded : Icons.cancel_rounded);

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        backgroundColor: AppColors.groupedBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () {
            AppMotion.tapHaptic();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goToHome();
            }
          },
        ),
        title: Text(
          'Safety Verdict',
          style: AppTypography.title2(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {
              AppMotion.tapHaptic();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SizedBox(height: AppSpacing.m),

            // Hero Radial Freshness & Safety Status Banner
            VerdictHeroCard(
              score: effectiveScore,
              title: verdictTitle,
              color: verdictColor,
              backgroundColor: verdictBg,
              borderColor: verdictBorder,
              icon: verdictIcon,
            ),
            const SizedBox(height: AppSpacing.l),

            // Identified Species Card
            VerdictSpeciesCard(
              speciesName: effectiveSpeciesName,
              riskTier: riskTier,
              confidencePercent: confidence,
            ),
            const SizedBox(height: AppSpacing.l),

            // Visual & Sensory Explainability Card
            VerdictExplainabilityCard(
              isSafe: isSafe,
              isCaution: effectiveIsCaution,
              isAvoid: effectiveIsAvoid,
              reasons: scanResult?.verdict.reasons,
              recommendation: scanResult?.verdict.recommendation,
              eyeScore: scanResult?.vision.eyeScore,
              gillScore: scanResult?.vision.gillScore,
              eyeBbox: scanResult?.vision.eyeBbox,
              gillBbox: scanResult?.vision.gillBbox,
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),

      // Bottom Action Bar: Done & Save to Cold Chain Timer
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppShadows.subtle,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSpacing.primaryButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        VerdictDialogs.showColdChainConfirmation(context),
                    icon: const Icon(Icons.timer_outlined, size: 20),
                    label: const Text('2h Cold-Chain Alert'),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: SizedBox(
                  height: AppSpacing.primaryButtonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      AppMotion.tapHaptic();
                      context.goToHome();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Done',
                      style: AppTypography.headline(color: AppColors.textInverse),
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
