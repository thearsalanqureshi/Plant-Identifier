import 'dart:math' as math;
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/camera_route.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/scanner_camera_options.dart';
import '../../../view_models/scanner_view_model.dart';
import '../../l10n/app_localizations.dart';
import 'scanner_preview_screen.dart';
import '../widgets/camera/camera_widgets.dart';

enum _ScannerExpandedTopControl {
  overlay,
  timer,
  aspectRatio,
  flash,
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  bool _isCapturing = false;
  bool _isPreviewTransitionActive = false;
  bool _argsApplied = false;
  _ScannerExpandedTopControl? _expandedTopControl;
  bool _isScalingGesture = false;
  double _gestureStartZoom = 1.0;
  double _lastRequestedZoom = 1.0;
  ScannerViewModel? _scannerViewModel;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _preloadCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scannerViewModel ??= context.read<ScannerViewModel>();
    _initializeArguments();
  }

  @override
  void dispose() {
    _scannerViewModel?.cancelCaptureCountdown();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topInset = MediaQuery.of(context).padding.top;
    final isSmallDevice = screenHeight < 700;
    final dockHeight = (screenHeight * 0.14).clamp(108.0, 120.0).toDouble();
    // Keep a fixed header slot so the compact and expanded rows share one anchor.
    final headerInnerHeight = 88.0;

    return Consumer<ScannerViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: _buildPreviewRegion(context, viewModel),
              ),
              if (_expandedTopControl != null)
                Positioned.fill(
                  top: topInset + headerInnerHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _collapseTopControl,
                    child: const SizedBox.expand(),
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTopHeader(context, viewModel, headerInnerHeight),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
    top: false,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildBottomDock(
                    context,
                    viewModel,
                    screenWidth,
                    dockHeight,
                    isSmallDevice,
                  ),
                ),
              ),
              ),
              if (_isPreviewTransitionActive)
                const Positioned.fill(
                  child: ModalBarrier(
                    color: AppColors.black,
                    dismissible: false,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    ScannerViewModel viewModel,
    double headerInnerHeight,
  ) {
    final bool immersiveChrome = viewModel.aspectRatio == ScannerAspectRatio.full;
    final double headerContentTopInset =
        _resolveHeaderContentTopInset(MediaQuery.sizeOf(context).height);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      height: headerInnerHeight,
      width: double.infinity,
      alignment: Alignment.topCenter,
      color: _scannerChromeColor(immersiveChrome),
      padding: EdgeInsets.fromLTRB(12, headerContentTopInset, 12, 0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 660),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              alignment: Alignment.topCenter,
              scale: Tween<double>(begin: 0.97, end: 1.0).animate(fade),
              child: child,
            ),
          );
        },
        child: _expandedTopControl == null
            ? KeyedSubtree(
                key: const ValueKey<String>('compact_top_row'),
                child: _buildCompactTopHeader(context, viewModel),
              )
            : KeyedSubtree(
                key: ValueKey<String>(
                  'expanded_${_expandedTopControl!.name}',
                ),
                child: _buildExpandedTopHeader(context, viewModel),
              ),
      ),
    );
  }

  Widget _buildCompactTopHeader(
    BuildContext context,
    ScannerViewModel viewModel,
  ) {
    final bool overlaySelected = viewModel.overlayMode.isActive;
    final bool timerSelected =
        viewModel.captureTimerOption != ScannerCaptureTimerOption.off;
    final bool aspectSelected =
        viewModel.aspectRatio != ScannerAspectRatio.ratio3x4;
    final Color flashColor =
        viewModel.isFlashOn ? AppColors.cameraAccent : AppColors.white;

    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: CameraRoundActionButton(
                icon: Icons.close,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: CameraTopGlyphButton(
                size: 44,
                selected: overlaySelected,
                onTap: () => _toggleExpandedTopControl(
                  viewModel,
                  _ScannerExpandedTopControl.overlay,
                ),
                child: CameraBracketFrame(
                  size: 16,
                  color: overlaySelected
                      ? AppColors.cameraAccent
                      : AppColors.white,
                  strokeWidth: 2.0,
                  cornerRadiusFactor: 0.24,
                  cornerLengthFactor: 0.30,
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: CameraTopGlyphButton(
                selected: timerSelected,
                onTap: () => _toggleExpandedTopControl(
                  viewModel,
                  _ScannerExpandedTopControl.timer,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 22,
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: CameraAspectRatioCompactBadge(
                label: viewModel.aspectRatio.label,
                selected: aspectSelected,
                onTap: () => _toggleExpandedTopControl(
                  viewModel,
                  _ScannerExpandedTopControl.aspectRatio,
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: CameraRoundActionButton(
                icon: viewModel.isFlashOn ? Icons.flash_on : Icons.flash_off,
                backgroundColor: AppColors.black.withOpacity(0.0),
                onTap: () => _toggleExpandedTopControl(
                  viewModel,
                  _ScannerExpandedTopControl.flash,
                ),
                iconColor: flashColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedTopHeader(
    BuildContext context,
    ScannerViewModel viewModel,
  ) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _collapseTopControl,
            child: const SizedBox.expand(),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 660),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final fade = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              );
              return FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(fade),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<String>(_expandedTopControl!.name),
              child: _buildExpandedOptionsRow(viewModel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedOptionsRow(ScannerViewModel viewModel) {
    switch (_expandedTopControl!) {
      case _ScannerExpandedTopControl.overlay:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CameraContextualOptionPill(
              label: 'Off',
              selected: viewModel.overlayMode == ScannerOverlayMode.off,
              onTap: () => _selectOverlayMode(
                viewModel,
                ScannerOverlayMode.off,
              ),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: 'Grid',
              selected: viewModel.overlayMode == ScannerOverlayMode.grid,
              onTap: () => _selectOverlayMode(
                viewModel,
                ScannerOverlayMode.grid,
              ),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: 'Focus',
              selected: viewModel.overlayMode == ScannerOverlayMode.focus,
              onTap: () => _selectOverlayMode(
                viewModel,
                ScannerOverlayMode.focus,
              ),
            ),
          ],
        );
      case _ScannerExpandedTopControl.timer:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CameraContextualOptionPill(
              label: 'Off',
              selected:
                  viewModel.captureTimerOption == ScannerCaptureTimerOption.off,
              onTap: () => _selectTimerOption(
                viewModel,
                ScannerCaptureTimerOption.off,
              ),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: '3s',
              selected: viewModel.captureTimerOption ==
                  ScannerCaptureTimerOption.threeSeconds,
              onTap: () => _selectTimerOption(
                viewModel,
                ScannerCaptureTimerOption.threeSeconds,
              ),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: '5s',
              selected: viewModel.captureTimerOption ==
                  ScannerCaptureTimerOption.fiveSeconds,
              onTap: () => _selectTimerOption(
                viewModel,
                ScannerCaptureTimerOption.fiveSeconds,
              ),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: '10s',
              selected: viewModel.captureTimerOption ==
                  ScannerCaptureTimerOption.tenSeconds,
              onTap: () => _selectTimerOption(
                viewModel,
                ScannerCaptureTimerOption.tenSeconds,
              ),
            ),
          ],
        );
      case _ScannerExpandedTopControl.aspectRatio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CameraContextualOptionPill(
              label: ScannerAspectRatio.ratio3x4.label,
              selected: viewModel.aspectRatio == ScannerAspectRatio.ratio3x4,
              onTap: () => _selectAspectRatio(
                viewModel,
                ScannerAspectRatio.ratio3x4,
              ),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: ScannerAspectRatio.ratio1x1.label,
              selected: viewModel.aspectRatio == ScannerAspectRatio.ratio1x1,
              onTap: () => _selectAspectRatio(
                viewModel,
                ScannerAspectRatio.ratio1x1,
              ),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: ScannerAspectRatio.ratio9x16.label,
              selected: viewModel.aspectRatio == ScannerAspectRatio.ratio9x16,
              onTap: () => _selectAspectRatio(
                viewModel,
                ScannerAspectRatio.ratio9x16,
              ),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: ScannerAspectRatio.full.label,
              selected: viewModel.aspectRatio == ScannerAspectRatio.full,
              onTap: () => _selectAspectRatio(
                viewModel,
                ScannerAspectRatio.full,
              ),
            ),
          ],
        );
      case _ScannerExpandedTopControl.flash:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CameraContextualOptionPill(
              label: 'Off',
              selected: !viewModel.isFlashOn,
              onTap: () => _selectFlashEnabled(viewModel, false),
            ),
            const SizedBox(width: 8),
            CameraContextualOptionPill(
              label: 'On',
              selected: viewModel.isFlashOn,
              onTap: () => _selectFlashEnabled(viewModel, true),
            ),
          ],
        );
    }
  }

  Widget _buildPreviewRegion(
    BuildContext context,
    ScannerViewModel viewModel,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewRect = _resolvePreviewRect(
          constraints.biggest,
          viewModel.aspectRatio.value,
        );
        if (kDebugMode) {
          debugPrint(
            'Scanner preview viewport | ratio=${viewModel.aspectRatio.label} '
            'available=${constraints.biggest} rect=$previewRect',
          );
        }
        final previewSize = previewRect.size;
        final shortestSide = math.min(previewSize.width, previewSize.height);
        final focusOverlaySize = math.min(shortestSide * 0.38, 150.0);
        final tapFocusSize = math.min(shortestSide * 0.22, 84.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            AnimatedPositioned.fromRect(
              duration: const Duration(milliseconds: 480),
              curve: Curves.easeOutCubic,
              rect: previewRect,
              child: KeyedSubtree(
                key: ValueKey<String>(
                  'preview_viewport_${viewModel.aspectRatio.name}',
                ),
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) => _handlePreviewTap(
                          context,
                          viewModel,
                          details,
                          previewSize,
                        ),
                        onScaleStart: (_) => _handleScaleStart(viewModel),
                        onScaleUpdate: (details) =>
                            _handleScaleUpdate(viewModel, details),
                        onScaleEnd: (_) => _handleScaleEnd(),
                        child: CameraPreviewHost(
                          controller: viewModel.cameraController,
                          backgroundColor: Colors.black,
                          isReady: viewModel.isCameraInitialized &&
                              !viewModel.isInitializing,
                        ),
                      ),
                      if (viewModel.isGridEnabled)
                        const CameraRuleOfThirdsGridOverlay(),
                      if (viewModel.isFocusOverlayEnabled)
                        CameraFocusReticleOverlay(
                          normalizedPosition: const Offset(0.5, 0.5),
                          size: focusOverlaySize,
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      if (viewModel.showFocusReticle &&
                          viewModel.focusPoint != null)
                        CameraFocusReticleOverlay(
                          normalizedPosition: viewModel.focusPoint!,
                          size: tapFocusSize,
                          color: AppColors.cameraAccent,
                          strokeWidth: 2.2,
                        ),
                      if (viewModel.isCaptureTimerRunning)
                        CameraCountdownOverlay(
                          remainingSeconds: viewModel.captureCountdownRemaining,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomDock(
    BuildContext context,
    ScannerViewModel viewModel,
    double screenWidth,
    double dockHeight,
    bool isSmallDevice,
  ) {
    final bool immersiveChrome = viewModel.aspectRatio == ScannerAspectRatio.full;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: dockHeight,
        color: _scannerChromeColor(immersiveChrome),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CameraRoundActionButton(
                  icon: Icons.photo_library,
                  size: 48,
                  iconSize: 24,
                  backgroundColor: AppColors.black.withOpacity(0.0),
                  onTap: () => _pickFromGallery(context),
                ),
                CameraCaptureButton(
                  enabled: !_isCapturing &&
                      !_isPreviewTransitionActive &&
                      !viewModel.isCaptureTimerRunning,
                  size: isSmallDevice ? 64 : 72,
                  iconSize: 32,
                  onTap: () => _captureImage(context),
                ),
                SizedBox(width: screenWidth * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _scannerChromeColor(bool immersiveChrome) {
    return immersiveChrome
        ? Colors.black.withOpacity(0.25)
        : Colors.black;
  }

  double _resolveHeaderContentTopInset(double screenHeight) {
    return math.max(
      8.0,
      math.min(11.0, screenHeight * 0.0105),
    ).toDouble();
  }

  Rect _resolvePreviewRect(Size availableSize, double? aspectRatio) {
    if (availableSize.isEmpty) {
      return Rect.zero;
    }

    if (aspectRatio == null || aspectRatio <= 0) {
      return Offset.zero & availableSize;
    }

    final availableRatio = availableSize.width / availableSize.height;
    late final double width;
    late final double height;

    if (availableRatio > aspectRatio) {
      height = availableSize.height;
      width = height * aspectRatio;
    } else {
      width = availableSize.width;
      height = width / aspectRatio;
    }

    final left = (availableSize.width - width) / 2;
    final top = (availableSize.height - height) / 2;
    return Rect.fromLTWH(left, top, width, height);
  }

  void _toggleExpandedTopControl(
    ScannerViewModel viewModel,
    _ScannerExpandedTopControl control,
  ) {
    if (_isCapturing ||
        _isPreviewTransitionActive ||
        viewModel.isCaptureTimerRunning) {
      return;
    }

    setState(() {
      _expandedTopControl =
          _expandedTopControl == control ? null : control;
    });
  }

  void _collapseTopControl() {
    if (!mounted || _expandedTopControl == null) {
      return;
    }

    setState(() {
      _expandedTopControl = null;
    });
  }

  Future<void> _selectOverlayMode(
    ScannerViewModel viewModel,
    ScannerOverlayMode mode,
  ) async {
    viewModel.setOverlayMode(mode);
    _collapseTopControl();
  }

  Future<void> _selectTimerOption(
    ScannerViewModel viewModel,
    ScannerCaptureTimerOption option,
  ) async {
    viewModel.setCaptureTimerOption(option);
    _collapseTopControl();
  }

  Future<void> _selectAspectRatio(
    ScannerViewModel viewModel,
    ScannerAspectRatio aspectRatio,
  ) async {
    viewModel.setAspectRatio(aspectRatio);
    _collapseTopControl();
  }

  Future<void> _selectFlashEnabled(
    ScannerViewModel viewModel,
    bool enabled,
  ) async {
    await viewModel.setFlashEnabled(enabled);
    _collapseTopControl();
  }

  Future<void> _captureImage(BuildContext context) async {
    if (_isCapturing || _isPreviewTransitionActive) return;

    _isCapturing = true;

    try {
      final viewModel = context.read<ScannerViewModel>();
      final bool proceedToCapture = await viewModel.startCaptureCountdown();
      if (!mounted || !proceedToCapture) {
        return;
      }

      final File? imageFile = await viewModel.captureImage();

      if (imageFile != null && mounted) {
        await _navigateToPreview(
          context,
          imageFile,
          viewModel.currentMode,
        );
      }
    } catch (_) {
      _setPreviewTransitionActive(false);
      _showError(AppLocalizations.of(context).scanner_capture_error);
    } finally {
      if (!mounted) {
        _isCapturing = false;
        return;
      }

      Future.delayed(const Duration(milliseconds: 700), () {
        _isCapturing = false;
      });
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    if (_isCapturing || _isPreviewTransitionActive) return;

    try {
      final viewModel = context.read<ScannerViewModel>();
      final File? imageFile = await viewModel.pickImageFromGallery();

      if (imageFile != null && mounted) {
        await _navigateToPreview(
          context,
          imageFile,
          viewModel.currentMode,
        );
      }
    } catch (_) {
      _setPreviewTransitionActive(false);
      _showError(AppLocalizations.of(context).scanner_gallery_error);
    }
  }

  Future<void> _navigateToPreview(
    BuildContext context,
    File imageFile,
    String mode,
  ) async {
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      CameraRoute.blackFade(
        routeName: AppRoutes.scannerPreview,
        child: ScannerPreviewScreen(
          initialImageFile: imageFile,
          initialMode: mode,
          onFirstFrame: _releasePreviewTransitionShield,
        ),
        arguments: {'imageFile': imageFile, 'mode': mode},
      ),
    );
  }

  void _setPreviewTransitionActive(bool value) {
    if (!mounted || _isPreviewTransitionActive == value) {
      return;
    }

    setState(() {
      _isPreviewTransitionActive = value;
    });
  }

  void _releasePreviewTransitionShield() {
    if (!mounted || !_isPreviewTransitionActive) {
      return;
    }

    setState(() {
      _isPreviewTransitionActive = false;
    });
  }

  Future<void> _handlePreviewTap(
    BuildContext context,
    ScannerViewModel viewModel,
    TapUpDetails details,
    Size previewSize,
  ) async {
    if (_isCapturing ||
        _isPreviewTransitionActive ||
        viewModel.isCaptureTimerRunning ||
        _isScalingGesture ||
        !viewModel.isCameraInitialized) {
      return;
    }

    final normalizedPoint = _normalizePreviewPoint(
      details.localPosition,
      previewSize,
    );

    await viewModel.focusCameraAt(normalizedPoint);
  }

  void _handleScaleStart(ScannerViewModel viewModel) {
    if (_isCapturing ||
        _isPreviewTransitionActive ||
        viewModel.isCaptureTimerRunning ||
        !viewModel.isCameraInitialized) {
      return;
    }

    _isScalingGesture = true;
    _gestureStartZoom = viewModel.zoomLevel;
    _lastRequestedZoom = viewModel.zoomLevel;
  }

  void _handleScaleUpdate(
    ScannerViewModel viewModel,
    ScaleUpdateDetails details,
  ) {
    if (!_isScalingGesture ||
        _isCapturing ||
        _isPreviewTransitionActive ||
        viewModel.isCaptureTimerRunning ||
        !viewModel.isCameraInitialized) {
      return;
    }

    final targetZoom = _gestureStartZoom * details.scale;
    if ((targetZoom - _lastRequestedZoom).abs() < 0.02) {
      return;
    }

    _lastRequestedZoom = targetZoom;
    unawaited(viewModel.setZoomLevel(targetZoom));
  }

  void _handleScaleEnd() {
    _isScalingGesture = false;
  }

  Offset _normalizePreviewPoint(Offset localPosition, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return const Offset(0.5, 0.5);
    }

    final clampedDx = localPosition.dx.clamp(0.0, size.width);
    final clampedDy = localPosition.dy.clamp(0.0, size.height);
    return Offset(
      (clampedDx / size.width).clamp(0.0, 1.0).toDouble(),
      (clampedDy / size.height).clamp(0.0, 1.0).toDouble(),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _initializeArguments() {
    if (_argsApplied) return;
    _argsApplied = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final viewModel = context.read<ScannerViewModel>();
      viewModel.setMode((args['mode'] ?? 'identify') as String);
    }
  }

  void _preloadCamera() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final viewModel = context.read<ScannerViewModel>();
      final success = await viewModel.initializeCamera();

      if (!mounted) {
        return;
      }

      _fadeController.forward();

      if (!success && viewModel.error.isNotEmpty) {
        _showError(viewModel.error);
      }
    });
  }
}
