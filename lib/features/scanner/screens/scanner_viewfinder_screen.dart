import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/routing/routing.dart';
import '../widgets/viewfinder_backdrop.dart';
import '../widgets/viewfinder_ar_guide.dart';
import '../widgets/viewfinder_top_controls.dart';
import '../widgets/viewfinder_shutter_button.dart';
import '../viewmodels/scanner_viewmodel.dart';
import 'sensory_check_bottom_sheet.dart';

/// Camera Viewfinder Screen with 2-Step Inspection Flow.
/// Refactored to adhere to SOLID: delegates backdrop, AR guide, top controls,
/// and shutter button to single-responsibility widgets.
class ScannerViewfinderScreen extends ConsumerStatefulWidget {
  const ScannerViewfinderScreen({super.key});

  @override
  ConsumerState<ScannerViewfinderScreen> createState() =>
      _ScannerViewfinderScreenState();
}

class _ScannerViewfinderScreenState extends ConsumerState<ScannerViewfinderScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 1; // 1: Whole fish, 2: Eye & Gill
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: AppMotion.breathe,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> _onShutterPressed() async {
    final vm = ref.read(scannerViewModelProvider.notifier);

    if (_currentStep == 1) {
      AppMotion.lockOnHaptic();
      vm.captureStep1();
      setState(() {
        _currentStep = 2;
      });
    } else {
      AppMotion.tapHaptic();
      // Step 2 captured -> execute ML species & vision detection
      final species = await vm.captureStep2AndDetectSpecies();

      if (!mounted) return;

      // Open sensory check sheet displaying the detected species
      final result = await SensoryCheckBottomSheet.show(
        context,
        speciesName: species.displayName,
      );

      if (result != null && mounted) {
        context.goToVerdict(VerdictRouteArgs.fromScanResult(result));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Simulated Camera Backdrop
          const ViewfinderBackdrop(),

          // 2. AR Bounding Box & Guide Overlay
          AnimatedBuilder(
            animation: _breatheController,
            builder: (context, child) {
              return ViewfinderArGuide(
                step: _currentStep,
                breatheOpacity: 0.65 + _breatheController.value * 0.35,
                scanProgress: _breatheController.value,
              );
            },
          ),

          // 3. Top Controls (Back, Flash, Distance Indicator, Offline Status)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: ViewfinderTopControls(
                step: _currentStep,
                isTorchOn: scannerState.isTorchOn,
                onClose: () => Navigator.of(context).pop(),
                onToggleTorch: () {
                  ref.read(scannerViewModelProvider.notifier).toggleTorch();
                  AppMotion.selectionHaptic();
                },
              ),
            ),
          ),

          // 4. Bottom Controls: Shutter Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                child: Center(
                  child: ViewfinderShutterButton(
                    onPressed: _onShutterPressed,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
