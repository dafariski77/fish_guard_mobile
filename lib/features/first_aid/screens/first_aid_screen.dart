import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../models/poisoning_condition_model.dart';
import '../widgets/emergency_banner.dart';
import '../widgets/poisoning_condition_card.dart';

/// Offline Fish Poisoning First-Aid Guide Screen (100% Offline Reference).
/// Refactored to adhere to SOLID: delegates emergency alerts and condition sections
/// to focused Single Responsibility widgets.
class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  static const List<PoisoningConditionModel> _conditions = [
    PoisoningConditionModel(
      title: 'Histamine (Scombroid) Poisoning',
      subtitle: 'Common in Tongkol, Cakalang, Kembung, Tenggiri',
      tagColor: AppColors.riskHistamineText,
      tagBg: AppColors.riskHistamineBg,
      tagName: 'Most Frequent',
      onsetTime: '10 – 60 minutes after eating',
      symptoms: [
        'Sudden facial flushing & intense throbbing headache',
        'Itchy hives, red rash on upper body, or burning mouth sensation',
        'Nausea, vomiting, abdominal cramps, diarrhea',
        'Palpitations or rapid heart rate',
      ],
      firstAidSteps: [
        'Take over-the-counter antihistamines (Cetirizine / Diphenhydramine).',
        'Drink plenty of oral rehydration fluids or coconut water.',
        'Do not induce vomiting if patient is drowsy.',
        'Seek immediate medical care if breathing becomes difficult.',
      ],
    ),
    PoisoningConditionModel(
      title: 'Ciguatera Fish Poisoning (CFP)',
      subtitle: 'Bioaccumulated in large reef predators (Kerapu, Barracuda, Kakap)',
      tagColor: AppColors.riskCiguateraText,
      tagBg: AppColors.riskCiguateraBg,
      tagName: 'Neurotoxic',
      onsetTime: '2 – 24 hours after eating',
      symptoms: [
        'Temperature reversal: cold objects feel burning hot!',
        'Numbness and tingling in lips, tongue, hands, and feet',
        'Joint aches, muscle weakness, severe fatigue lasting weeks',
        'Vomiting, nausea, watery diarrhea',
      ],
      firstAidSteps: [
        'Visit an emergency room for intravenous hydration and mannitol evaluation.',
        'Strictly avoid alcohol, nuts, caffeine, and all fish for at least 3-6 months (prevents symptom flare-up).',
        'Keep patient warm and resting.',
      ],
    ),
    PoisoningConditionModel(
      title: 'Bacterial Spoilage & Formalin',
      subtitle: 'Decomposed fish or illegal chemical dipping',
      tagColor: Color(0xFF2563EB),
      tagBg: Color(0xFFEFF6FF),
      tagName: 'Gastrointestinal',
      onsetTime: '6 – 48 hours (Bacterial) / Immediate (Formalin)',
      symptoms: [
        'Formalin: burning sensation in mouth/throat, sharp stomach pains',
        'Bacterial: severe watery or bloody diarrhea, high fever, chills',
        'Severe dizziness from dehydration',
      ],
      firstAidSteps: [
        'Formalin exposure: Drink clean water or milk immediately. Do NOT induce vomiting. Go directly to ER.',
        'Bacterial: Rehydrate aggressively with oral rehydration salts (ORS/Oralit).',
        'Consult physician for stool culture and targeted antibiotics.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        backgroundColor: AppColors.groupedBackground,
        elevation: 0,
        title: Text('Fish Poisoning Guide', style: AppTypography.headline()),
        actions: const [
          _OfflineGuideBadge(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SizedBox(height: AppSpacing.s),

            // Emergency ER Red Flags Banner
            const EmergencyBanner(),
            const SizedBox(height: AppSpacing.l),

            // Poisoning Conditions
            ..._conditions.map((cond) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.l),
                  child: PoisoningConditionCard(condition: cond),
                )),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _OfflineGuideBadge extends StatelessWidget {
  const _OfflineGuideBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.l),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text('100% Offline', style: AppTypography.caption1(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
