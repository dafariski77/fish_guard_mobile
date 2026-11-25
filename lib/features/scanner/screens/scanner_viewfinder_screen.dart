import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/routing/routing.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/app_logger.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../widgets/viewfinder_ar_guide.dart';
import '../widgets/viewfinder_backdrop.dart';
import '../widgets/viewfinder_shutter_button.dart';
import '../widgets/viewfinder_top_controls.dart';
import 'sensory_check_bottom_sheet.dart';

/// Camera Viewfinder Screen with 2-Step Inspection Flow and live CameraX/AVFoundation feed.
/// Falls back gracefully to [ViewfinderBackdrop] when camera hardware is unavailable
/// (e.g., simulators or headless widget tests).
class ScannerViewfinderScreen extends ConsumerStatefulWidget {
  const ScannerViewfinderScreen({super.key});

  @override
  ConsumerState<ScannerViewfinderScreen> createState() =>
      _ScannerViewfinderScreenState();
}

class _ScannerViewfinderScreenState
    extends ConsumerState<ScannerViewfinderScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentStep = 1; // 1: Whole fish, 2: Eye & Gill
  late AnimationController _breatheController;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _breatheController = AnimationController(
      vsync: this,
      duration: AppMotion.breathe,
    );
    if (!const bool.fromEnvironment('FLUTTER_TEST')) {
      _breatheController.repeat(reverse: true);
    }
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraError = 'No camera detected on this device.');
        }
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      _cameraController = controller;
      setState(() {
        _isCameraInitialized = true;
        _cameraError = null;
      });
    } on CameraException catch (e) {
      if (mounted) {
        final detail = (e.description != null && e.description!.isNotEmpty)
            ? ' — ${e.description}'
            : '';
        setState(() {
          _isCameraInitialized = false;
          _cameraError = e.code == 'CameraAccessDenied'
              ? 'Camera permission denied. Enable it in Settings.'
              : e.code == 'channel-error'
                  ? 'Camera plugin not initialized. Please stop and rebuild the app (flutter run)$detail'
                  : 'Camera unavailable (${e.code})$detail';
        });
      }
    } catch (_) {
      // Headless / unsupported platform fallback
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _breatheController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<String?> _captureFrame() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return null;
    }
    if (controller.value.isTakingPicture) return null;

    try {
      final file = await controller.takePicture();
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onToggleTorch() async {
    final notifier = ref.read(scannerViewModelProvider.notifier);
    notifier.toggleTorch();
    AppMotion.selectionHaptic();

    final isTorchOn = ref.read(scannerViewModelProvider).isTorchOn;
    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      try {
        await controller.setFlashMode(
          isTorchOn ? FlashMode.torch : FlashMode.off,
        );
      } catch (_) {}
    }
  }

  Future<void> _onShutterPressed() async {
    if (_isCapturing || ref.read(scannerViewModelProvider).isProcessing) {
      return;
    }

    setState(() => _isCapturing = true);
    final vm = ref.read(scannerViewModelProvider.notifier);

    try {
      final capturedPath = await _captureFrame();

      if (_currentStep == 1) {
        AppMotion.lockOnHaptic();
        vm.captureStep1(imagePath: capturedPath);
        if (mounted) {
          setState(() => _currentStep = 2);
        }
      } else {
        AppMotion.tapHaptic();
        // Step 2 captured -> execute on-device TFLite species & vision detection
        final species = await vm.captureStep2AndDetectSpecies(
          imagePath: capturedPath,
        );

        if (!mounted) return;

        // Turn off torch before opening sensory bottom sheet
        if (ref.read(scannerViewModelProvider).isTorchOn) {
          await _onToggleTorch();
        }
        if (!mounted) return;

        final result = await SensoryCheckBottomSheet.show(
          context,
          speciesName: species.displayName,
        );

        if (result != null && mounted) {
          context.goToVerdict(VerdictRouteArgs.fromScanResult(result));
        }
      }
    } on Object catch (e, st) {
      await AppLogger.error(
        'Scanner',
        'Scan failed at step $_currentStep',
        e,
        st,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Scan model error: $e'),
          backgroundColor: AppColors.verdictAvoid,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.goToHome();
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Widget _buildCameraLayer() {
    final controller = _cameraController;
    if (_isCameraInitialized &&
        controller != null &&
        controller.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 1080,
            height: controller.value.previewSize?.width ?? 1920,
            child: CameraPreview(controller),
          ),
        ),
      );
    }
    return const ViewfinderBackdrop();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerViewModelProvider);
    final isBusy = _isCapturing || scannerState.isProcessing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Preview (or simulated backdrop when unavailable)
          _buildCameraLayer(),

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
                onToggleTorch: _onToggleTorch,
              ),
            ),
          ),

          // 4. Optional Camera Permission / Error Pill
          if (_cameraError != null)
            Positioned(
              top: 120,
              left: AppSpacing.l,
              right: AppSpacing.l,
              child: Material(
                color: Colors.black.withAlpha(180),
                borderRadius: AppRadius.borderButton,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.videocam_off_rounded,
                        color: AppColors.verdictCaution,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          _cameraError!,
                          style: AppTypography.caption1(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: _initCamera,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Processing Overlay during TFLite Inference
          if (scannerState.isProcessing)
            Container(
              color: Colors.black.withAlpha(140),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.m,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppRadius.borderCard,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        'Analyzing species & freshness...',
                        style: AppTypography.bodySemiBold(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 6. Bottom Controls: Shutter Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                child: Center(
                  child: AbsorbPointer(
                    absorbing: isBusy,
                    child: Opacity(
                      opacity: isBusy ? 0.55 : 1.0,
                      child: ViewfinderShutterButton(
                        onPressed: _onShutterPressed,
                      ),
                    ),
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
