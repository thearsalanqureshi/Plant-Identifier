import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../data/services/analytics_service.dart';
import '../data/services/camera_manager.dart';
import '../data/models/scanner_camera_options.dart';
import '../data/services/scanner_service.dart';

class ScannerViewModel with ChangeNotifier {
  final ScannerService _scannerService;
  final CameraManager _cameraManager = CameraManager();

  bool _isDisposed = false;
  bool _isInitializing = false;
  bool _isCameraSessionAttached = false;
  int _cameraLifecycleToken = 0;
  String _currentMode = 'identify';
  String _error = '';
  double _cameraOpacity = 0.0;
  double _zoomLevel = 1.0;
  Offset? _focusPoint;
  bool _showFocusReticle = false;
  ScannerAspectRatio _aspectRatio = ScannerAspectRatio.ratio3x4;
  ScannerOverlayMode _overlayMode = ScannerOverlayMode.off;
  ScannerCaptureTimerOption _captureTimerOption =
      ScannerCaptureTimerOption.off;
  bool _isCaptureTimerRunning = false;
  int _captureCountdownRemaining = 0;
  Timer? _focusReticleTimer;
  Timer? _captureCountdownTimer;
  Completer<bool>? _captureCountdownCompleter;

  ScannerViewModel(this._scannerService) {
    _cameraManager.addListener(_onCameraManagerChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cameraLifecycleToken++;
    _focusReticleTimer?.cancel();
    _captureCountdownTimer?.cancel();
    _completeCaptureCountdown(false);
    _cameraManager.removeListener(_onCameraManagerChanged);

    if (_isCameraSessionAttached) {
      unawaited(_cameraManager.releaseCamera());
      _isCameraSessionAttached = false;
    }

    super.dispose();
  }

  CameraController? get cameraController => _cameraManager.controller;
  bool get isFlashOn => cameraController?.value.flashMode == FlashMode.torch;
  bool get isCameraInitialized => _cameraManager.hasController;
  bool get isInitializing => _cameraManager.isInitializing;
  String get currentMode => _currentMode;
  String get error => _error;
  double get cameraOpacity => _cameraOpacity;
  double get zoomLevel => _zoomLevel;
  Offset? get focusPoint => _focusPoint;
  bool get showFocusReticle => _showFocusReticle;
  ScannerAspectRatio get aspectRatio => _aspectRatio;
  ScannerOverlayMode get overlayMode => _overlayMode;
  bool get isGridEnabled => _overlayMode == ScannerOverlayMode.grid;
  bool get isFocusOverlayEnabled => _overlayMode == ScannerOverlayMode.focus;
  ScannerCaptureTimerOption get captureTimerOption => _captureTimerOption;
  bool get isCaptureTimerRunning => _isCaptureTimerRunning;
  int get captureCountdownRemaining => _captureCountdownRemaining;

  void _onCameraManagerChanged() {
    if (_isDisposed) {
      return;
    }

    _cameraOpacity = isCameraInitialized ? 1.0 : 0.0;
    _safeNotifyListeners();
  }

  Future<bool> initializeCamera() async {
    debugPrint('ScannerViewModel: initializeCamera() called');

    if (_isDisposed) {
      debugPrint('ScannerViewModel: view model disposed, skipping init');
      return false;
    }

    if (_isInitializing) {
      return isCameraInitialized;
    }

    if (_isCameraSessionAttached && isCameraInitialized) {
      _cameraOpacity = 1.0;
      _safeNotifyListeners();
      return true;
    }

    _isInitializing = true;
    _error = '';
    _cameraLifecycleToken++;
    final int requestToken = _cameraLifecycleToken;
    _safeNotifyListeners();

    bool acquiredNewSession = false;

    try {
      final CameraController? cameraController = _isCameraSessionAttached
          ? await _cameraManager.ensureCameraReady(forLightMeter: false)
          : await _cameraManager.acquireCamera(forLightMeter: false);

      acquiredNewSession = !_isCameraSessionAttached && cameraController != null;

      if (_isDisposed || requestToken != _cameraLifecycleToken) {
        if (acquiredNewSession) {
          await _cameraManager.releaseCamera();
        }
        return false;
      }

      if (cameraController == null || !cameraController.value.isInitialized) {
        _error = _cameraManager.lastError ?? 'Camera not available';
        debugPrint('ScannerViewModel: camera unavailable');

        AnalyticsService.logCameraError(
          errorType: 'camera_not_available',
          errorDetail: _error,
        );

        _cameraOpacity = 0.0;
        _safeNotifyListeners();
        return false;
      }

      _isCameraSessionAttached = true;
      final appliedZoom = await _cameraManager.applyScannerCameraSettings(
        zoomLevel: _zoomLevel,
        focusPoint: _focusPoint,
      );
      if (appliedZoom != null) {
        _zoomLevel = appliedZoom;
      }
      _cameraOpacity = 1.0;
      debugPrint('ScannerViewModel: camera initialized successfully');
      _safeNotifyListeners();
      return true;
    } catch (e) {
      if (_isDisposed || requestToken != _cameraLifecycleToken) {
        return false;
      }

      _error = 'Camera setup failed: $e';
      debugPrint('ScannerViewModel: camera initialization error: $e');

      AnalyticsService.logCameraError(
        errorType: 'initialization_failed',
        errorDetail: e.toString(),
      );

      if (acquiredNewSession) {
        await _cameraManager.releaseCamera();
      }

      _cameraOpacity = 0.0;
      _safeNotifyListeners();
      return false;
    } finally {
      _isInitializing = false;
      if (!_isDisposed) {
        _safeNotifyListeners();
      }
    }
  }

  void _safeNotifyListeners() {
    if (_isDisposed || !hasListeners) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && hasListeners) {
        notifyListeners();
      }
    });
  }

  Future<void> toggleFlash() async {
    await setFlashEnabled(!isFlashOn);
  }

  Future<void> setFlashEnabled(bool enabled) async {
    if (_isDisposed || !isCameraInitialized) {
      return;
    }

    await _cameraManager.setFlashEnabled(enabled);
    _safeNotifyListeners();
  }

  Future<void> setZoomLevel(double zoomLevel) async {
    if (_isDisposed || !isCameraInitialized) {
      return;
    }

    final appliedZoom = await _cameraManager.setZoomLevel(zoomLevel);
    if (_isDisposed || appliedZoom == null) {
      return;
    }

    if ((_zoomLevel - appliedZoom).abs() < 0.01) {
      return;
    }

    _zoomLevel = appliedZoom;
    _safeNotifyListeners();
  }

  Future<void> focusCameraAt(Offset normalizedPoint) async {
    if (_isDisposed || !isCameraInitialized) {
      return;
    }

    final clampedPoint = Offset(
      normalizedPoint.dx.clamp(0.0, 1.0).toDouble(),
      normalizedPoint.dy.clamp(0.0, 1.0).toDouble(),
    );

    _focusPoint = clampedPoint;
    _showFocusReticle = true;
    _focusReticleTimer?.cancel();
    _focusReticleTimer = Timer(const Duration(milliseconds: 900), () {
      if (_isDisposed) {
        return;
      }

      _showFocusReticle = false;
      _safeNotifyListeners();
    });
    _safeNotifyListeners();

    await _cameraManager.setFocusPoint(clampedPoint);
  }

  void setAspectRatio(ScannerAspectRatio aspectRatio) {
    if (_isDisposed || _isCaptureTimerRunning || _aspectRatio == aspectRatio) {
      return;
    }

    _aspectRatio = aspectRatio;
    _safeNotifyListeners();
  }

  void setOverlayMode(ScannerOverlayMode mode) {
    if (_isDisposed || _isCaptureTimerRunning || _overlayMode == mode) {
      return;
    }

    _overlayMode = mode;
    _safeNotifyListeners();
  }

  void toggleGridOverlay() {
    setOverlayMode(
      _overlayMode == ScannerOverlayMode.grid
          ? ScannerOverlayMode.off
          : ScannerOverlayMode.grid,
    );
  }

  void setGridOverlayEnabled(bool enabled) {
    setOverlayMode(
      enabled ? ScannerOverlayMode.grid : ScannerOverlayMode.off,
    );
  }

  void setCaptureTimerOption(ScannerCaptureTimerOption option) {
    if (_isDisposed || _isCaptureTimerRunning || _captureTimerOption == option) {
      return;
    }

    _captureTimerOption = option;
    _safeNotifyListeners();
  }

  Future<bool> startCaptureCountdown() async {
    if (_isDisposed) {
      return false;
    }

    final seconds = _captureTimerOption.seconds;
    if (seconds == null || seconds <= 0) {
      return true;
    }

    if (_isCaptureTimerRunning) {
      return _captureCountdownCompleter?.future ?? Future.value(false);
    }

    _isCaptureTimerRunning = true;
    _captureCountdownRemaining = seconds;
    _captureCountdownCompleter = Completer<bool>();
    _captureCountdownTimer?.cancel();
    _safeNotifyListeners();

    _captureCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        _completeCaptureCountdown(false);
        return;
      }

      _captureCountdownRemaining--;
      if (_captureCountdownRemaining <= 0) {
        timer.cancel();
        _completeCaptureCountdown(true);
        return;
      }

      _safeNotifyListeners();
    });

    return _captureCountdownCompleter!.future;
  }

  void cancelCaptureCountdown() {
    _completeCaptureCountdown(false);
  }

  void _completeCaptureCountdown(bool completed) {
    _captureCountdownTimer?.cancel();
    _captureCountdownTimer = null;

    if (!_isCaptureTimerRunning && _captureCountdownCompleter == null) {
      return;
    }

    _isCaptureTimerRunning = false;
    _captureCountdownRemaining = 0;

    final completer = _captureCountdownCompleter;
    _captureCountdownCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(completed);
    }

    _safeNotifyListeners();
  }

  Future<File?> captureImage() async {
    debugPrint('ScannerViewModel: captureImage() called');

    if (_isDisposed) {
      debugPrint('ScannerViewModel: disposed, skipping capture');
      return null;
    }

    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) {
      debugPrint('ScannerViewModel: camera not ready');

      AnalyticsService.logCameraError(
        errorType: 'camera_not_ready',
        errorDetail: 'Camera controller not initialized',
      );

      throw Exception('Camera not ready');
    }

    try {
      final xFile = await controller.takePicture();

      if (_isDisposed) {
        return null;
      }

      final File imageFile = File(xFile.path);

      final exists = await imageFile.exists();
      if (!exists) {
        AnalyticsService.logCameraError(
          errorType: 'file_not_found',
          errorDetail: 'Captured file does not exist on disk',
        );
        return null;
      }

      AnalyticsService.logCameraUsed(
        source: 'camera',
        mode: _currentMode,
      );

      return imageFile;
    } catch (e, stackTrace) {
      debugPrint('ScannerViewModel: capture error: $e');
      debugPrint('Stack trace: $stackTrace');

      AnalyticsService.logCameraError(
        errorType: 'capture_failed',
        errorDetail: e.toString(),
      );

      if (!_isDisposed) {
        Future.microtask(() {
          if (!_isDisposed) {
            _error = 'Capture failed: $e';
            _safeNotifyListeners();
          }
        });
      }

      rethrow;
    }
  }

  Future<File?> pickImageFromGallery() async {
    debugPrint('ScannerViewModel: pickImageFromGallery() called');

    if (_isDisposed) {
      debugPrint('ScannerViewModel: disposed, skipping gallery pick');
      return null;
    }

    try {
      final xFile = await _scannerService.pickImageFromGallery();

      if (_isDisposed) {
        return null;
      }

      if (xFile == null) {
        debugPrint('ScannerViewModel: no image selected from gallery');
        return null;
      }

      final File imageFile = File(xFile.path);

      final exists = await imageFile.exists();
      if (!exists) {
        debugPrint('ScannerViewModel: gallery file does not exist on disk');
        return null;
      }

      AnalyticsService.logCameraUsed(
        source: 'gallery',
        mode: _currentMode,
      );

      return imageFile;
    } catch (e, stackTrace) {
      debugPrint('ScannerViewModel: gallery pick error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!_isDisposed) {
        Future.microtask(() {
          if (!_isDisposed) {
            _error = 'Gallery pick failed: $e';
            _safeNotifyListeners();
          }
        });
      }

      rethrow;
    }
  }

  void setMode(String mode) {
    if (_isDisposed) {
      return;
    }

    if (_currentMode != mode) {
      _currentMode = mode;
      _safeNotifyListeners();
    }
  }

  Future<bool> reinitializeCamera() async {
    debugPrint('ScannerViewModel: reinitializeCamera() called');

    if (_isDisposed) {
      return false;
    }

    if (isCameraInitialized && _isCameraSessionAttached) {
      _cameraOpacity = 1.0;
      _safeNotifyListeners();
      return true;
    }

    return initializeCamera();
  }

  Future<void> disposeCamera() async {
    await detachCameraSession();
  }

  Future<void> detachCameraSession() async {
    debugPrint('ScannerViewModel: detachCameraSession() called');

    _cameraLifecycleToken++;

    if (_isCameraSessionAttached) {
      await _cameraManager.releaseCamera();
      _isCameraSessionAttached = false;
    }

    _cameraOpacity = isCameraInitialized ? 1.0 : 0.0;
    _safeNotifyListeners();
  }

  Future<void> forceDisposeCamera() async {
    debugPrint('ScannerViewModel: forceDisposeCamera() called');

    _cameraLifecycleToken++;
    _isCameraSessionAttached = false;
    _cameraOpacity = 0.0;
    await _cameraManager.forceDispose();
    _safeNotifyListeners();
  }

  bool isCameraAvailable() {
    return isCameraInitialized;
  }
}
