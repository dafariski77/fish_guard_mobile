import 'dart:io';

import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Single Responsibility widget that renders visual evidence, detection boxes, and plain-language bullets.
class VerdictExplainabilityCard extends StatelessWidget {
  final bool isSafe;
  final bool isCaution;
  final bool isAvoid;
  final List<String>? reasons;
  final String? recommendation;
  final double? eyeScore;
  final double? gillScore;
  final List<double>? eyeBbox;
  final List<double>? gillBbox;
  final String? imagePath;

  const VerdictExplainabilityCard({
    super.key,
    required this.isSafe,
    required this.isCaution,
    required this.isAvoid,
    this.reasons,
    this.recommendation,
    this.eyeScore,
    this.gillScore,
    this.eyeBbox,
    this.gillBbox,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBulletColor = isSafe
        ? AppColors.verdictSafe
        : (isCaution ? AppColors.verdictCaution : AppColors.verdictAvoid);

    final effectiveBulletIcon = isSafe
        ? Icons.check_circle_outline_rounded
        : (isCaution
            ? Icons.warning_amber_rounded
            : Icons.error_outline_rounded);

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Visual & Sensory Evidence',
                style: AppTypography.headline(color: AppColors.textPrimary),
              ),
              if (eyeScore != null && gillScore != null)
                Text(
                  'Eye: ${(eyeScore! * 100).round()}% | Gill: ${(gillScore! * 100).round()}%',
                  style: AppTypography.caption1(color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),

          // Eye & Gill Bounding Box Photo Preview
          _buildThumbnailPreview(),
          const SizedBox(height: AppSpacing.l),

          // Plain-language Explainability Bullets
          if (reasons != null && reasons!.isNotEmpty) ...[
            for (final reason in reasons!)
              _buildBulletPoint(effectiveBulletIcon, effectiveBulletColor, reason),
          ] else ...[
            if (isSafe) ...[
              _buildBulletPoint(
                Icons.check_circle_outline_rounded,
                AppColors.verdictSafe,
                'Clear cornea and healthy eye convexity.',
              ),
              _buildBulletPoint(
                Icons.check_circle_outline_rounded,
                AppColors.verdictSafe,
                'Gills show vibrant, natural reddish biological coloration.',
              ),
            ] else if (isCaution) ...[
              _buildBulletPoint(
                Icons.warning_amber_rounded,
                AppColors.verdictCaution,
                'Moderate biological freshness decline detected.',
              ),
            ] else ...[
              _buildBulletPoint(
                Icons.error_outline_rounded,
                AppColors.verdictAvoid,
                'Severe discoloration or decay detected. Do not consume.',
              ),
            ],
          ],

          if (recommendation != null && recommendation!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: isSafe
                    ? AppColors.verdictSafeBg
                    : (isCaution
                        ? AppColors.verdictCautionBg
                        : AppColors.verdictAvoidBg),
                borderRadius: AppRadius.borderButton,
                border: Border.all(
                  color: isSafe
                      ? AppColors.verdictSafeBorder
                      : (isCaution
                          ? AppColors.verdictCautionBorder
                          : AppColors.verdictAvoidBorder),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: effectiveBulletColor,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      recommendation!,
                      style: AppTypography.footnote(color: AppColors.textPrimary)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnailPreview() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: AppRadius.borderCard,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalW = constraints.maxWidth;
          const totalH = 140.0;

          // Eye normalized coordinates [x, y, w, h] or default fallback
          final eBox = (eyeBbox != null &&
                  eyeBbox!.length == 4 &&
                  eyeBbox![2] > 0 &&
                  eyeBbox![3] > 0)
              ? eyeBbox!
              : [0.25, 0.20, 0.35, 0.40];
          final eyeLeft = (eBox[0] * totalW).clamp(0.0, totalW - 40.0);
          final eyeTop = (eBox[1] * totalH).clamp(0.0, totalH - 30.0);
          final eyeWidth = (eBox[2] * totalW).clamp(36.0, totalW - eyeLeft);
          final eyeHeight = (eBox[3] * totalH).clamp(24.0, totalH - eyeTop);

          // Gill normalized coordinates [x, y, w, h] or default fallback
          final gBox = (gillBbox != null &&
                  gillBbox!.length == 4 &&
                  gillBbox![2] > 0 &&
                  gillBbox![3] > 0)
              ? gillBbox!
              : [0.65, 0.25, 0.30, 0.50];
          final gillLeft = (gBox[0] * totalW).clamp(0.0, totalW - 40.0);
          final gillTop = (gBox[1] * totalH).clamp(0.0, totalH - 30.0);
          final gillWidth = (gBox[2] * totalW).clamp(36.0, totalW - gillLeft);
          final gillHeight = (gBox[3] * totalH).clamp(24.0, totalH - gillTop);

          final hasFile = imagePath != null &&
              imagePath!.isNotEmpty &&
              File(imagePath!).existsSync();

          return ClipRRect(
            borderRadius: AppRadius.borderCard,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasFile)
                  Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    width: totalW,
                    height: totalH,
                  )
                else
                  Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
              // Eye Bounding Box Indicator
              Positioned(
                left: eyeLeft,
                top: eyeTop,
                width: eyeWidth,
                height: eyeHeight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: effectiveOverlayColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: effectiveOverlayColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      child: Text(
                        'EYE ${eyeScore != null ? "${(eyeScore! * 100).round()}%" : ""}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Gill Bounding Box Indicator
              Positioned(
                left: gillLeft,
                top: gillTop,
                width: gillWidth,
                height: gillHeight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: effectiveOverlayColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: effectiveOverlayColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      child: Text(
                        'GILL ${gillScore != null ? "${(gillScore! * 100).round()}%" : ""}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color get effectiveOverlayColor => isSafe
      ? AppColors.verdictSafe
      : (isCaution ? AppColors.verdictCaution : AppColors.verdictAvoid);

  Widget _buildBulletPoint(IconData icon, Color iconColor, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              text,
              style: AppTypography.subheadline(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
