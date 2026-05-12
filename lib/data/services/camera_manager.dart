import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraManager extends ChangeNotifier {
  static final CameraManager _instance = CameraManager._internal();

  factory CameraManager() => _instance;

  CameraManager._internal();

  CameraController? _controller;
  Future<CameraController?>? _initializationFuture;
  int _attachedClients = 0;
  int _generation = 0;
  bool _isPreviewPaused = false;
  String? _lastError;
  double? _minZoomLevel;
  double? _maxZoomLevel;
  Future<void> _zoomCommandQueue = Future.value();

  CameraController? get controller => _controller;
  bool get hasController => _controller?.value.isInitialized == true;
  bool get isInitializing => _initializationFuture != null;
  bool get isPreviewPaused => _isPreviewPaused;
  int get attachedClients => _attachedClients;
  String? get lastError => _lastError;
  double? get minZoomLevel => _minZoomLevel;
  double? get maxZoomLevel => _maxZoomLevel;

  Future<CameraController?> getCamera({bool forLightMeter = false}) {
    return acquireCamera(forLightMeter: forLightMeter);
  }

  Future<CameraController?> acquireCamera({bool forLightMeter = false}) async {
    final controller = await ensureCameraReady(forLightMeter: forLightMeter);
    if (controller == null) {
      return null;
    }

    _attachedClients++;
    _lastError = null;
    _notifyStateChanged();
    debugPrint(
      'CameraManager: attached controller for ${forLightMeter ? "light meter" : "scanner"} (clients: $_attachedClients)',
    );
    return controller;
  }

  Future<CameraController?> ensureCameraReady({
    bool forLightMeter = false,
  }) async {
    if (hasController) {
      return _controller;
    }

    final existingFuture = _initializationFuture;
    if (existingFuture != null) {
      return existingFuture;
    }

    final requestGeneration = _generation;
    final future = _initializeController(
      requestGeneration,
      forLightMeter: forLightMeter,
    );
    _initializationFuture = future;
    _notifyStateChanged();

    future.whenComplete(() {
      if (identical(_initializationFuture, future)) {
        _initializationFuture = null;
        _notifyStateChanged();
      }
    });

    return future;
  }

  Future<void> releaseCamera() async {
    if (_attachedClients > 0) {
      _attachedClients--;
    }

    debugPrint('CameraManager: detached client (clients: $_attachedClients)');
    _notifyStateChanged();
  }

  Future<void> detachCameraSession() => releaseCamera();

  Future<void> forceDispose() async {
    _generation++;
    _attachedClients = 0;
    _isPreviewPaused = false;
    _lastError = null;
    _minZoomLevel = null;
    _maxZoomLevel = null;

    final controller = _controller;
    _controller = null;
    _initializationFuture = null;

    if (controller != null) {
      await _disposeController(controller);
    }

    debugPrint('CameraManager: force disposed shared camera session');
    _notifyStateChanged();
  }

  Future<void> handleAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      await pausePreview();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      await resumePreview();
    }
  }

  Future<void> pausePreview() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isPreviewPaused) {
      return;
    }

    try {
      await controller.pausePreview();
      _isPreviewPaused = true;
      debugPrint('CameraManager: preview paused');
      _notifyStateChanged();
    } catch (e) {
      debugPrint('CameraManager: pausePreview failed: $e');
    }
  }

  Future<void> resumePreview() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      if (_attachedClients > 0) {
        await ensureCameraReady();
      }
      return;
    }

    if (!_isPreviewPaused) {
      return;
    }

    try {
      await controller.resumePreview();
      _isPreviewPaused = false;
      debugPrint('CameraManager: preview resumed');
      _notifyStateChanged();
    } catch (e) {
      debugPrint('CameraManager: resumePreview failed, rebuilding controller: $e');
      await _resetBrokenController(controller);

      if (_attachedClients > 0) {
        await ensureCameraReady();
      }
    }
  }

  Future<CameraController?> _initializeController(
    int requestGeneration, {
    required bool forLightMeter,
  }) async {
    _lastError = null;
    debugPrint(
      'CameraManager: initializing shared camera for ${forLightMeter ? "light meter" : "scanner"}',
    );

    CameraController? controller;

    try {
      final permissionStatus = await Permission.camera.status;
      final cameraPermission = permissionStatus.isGranted
          ? permissionStatus
          : await Permission.camera.request();

      if (!cameraPermission.isGranted) {
        _lastError = 'Camera permission denied';
        debugPrint('CameraManager: camera permission denied');
        _notifyStateChanged();
        return null;
      }

      final cameras = await availableCameras();
      if (requestGeneration != _generation) {
        return null;
      }

      if (cameras.isEmpty) {
        _lastError = 'No cameras available';
        debugPrint('CameraManager: no cameras available');
        _notifyStateChanged();
        return null;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        backCamera,
        // Use a high-quality preset so the preview and captured image are
        // not upscaled from a low-resolution stream.
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await controller.initialize();

      if (requestGeneration != _generation) {
        await _disposeController(controller);
        return null;
      }

      try {
        await controller.setFocusMode(FocusMode.auto);
      } catch (_) {
        // Focus mode is best-effort; unsupported devices can ignore it.
      }

      try {
        await controller.setExposureMode(ExposureMode.auto);
      } catch (_) {
        // Exposure mode is best-effort; unsupported devices can ignore it.
      }

      try {
        await controller.setFocusPoint(const Offset(0.5, 0.5));
      } catch (_) {
        // Center focus is best-effort.
      }

      try {
        await controller.setExposurePoint(const Offset(0.5, 0.5));
      } catch (_) {
        // Center exposure is best-effort.
      }

      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {
        // Flash mode is best-effort.
      }

      final staleController = _controller;
      if (staleController != null && staleController != controller) {
        await _disposeController(staleController);
      }

      _minZoomLevel = null;
      _maxZoomLevel = null;
      _controller = controller;
      _isPreviewPaused = false;
      _lastError = null;

      debugPrint('CameraManager: shared camera initialized successfully');
      _notifyStateChanged();
      return controller;
    } catch (e) {
      _lastError = 'Camera initialization failed: $e';
      debugPrint('CameraManager: camera initialization failed: $e');

      if (controller != null) {
        await _disposeController(controller);
      }

      final staleController = _controller;
      if (staleController != null && !staleController.value.isInitialized) {
        await _resetBrokenController(staleController);
      }

      _notifyStateChanged();
      return null;
    }
  }

  Future<void> _resetBrokenController(CameraController controller) async {
    if (_controller == controller) {
      _controller = null;
    }

    _isPreviewPaused = false;
    _minZoomLevel = null;
    _maxZoomLevel = null;
    await _disposeController(controller);
    _notifyStateChanged();
  }

  Future<void> refreshZoomBounds() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      _minZoomLevel = await controller.getMinZoomLevel();
      _maxZoomLevel = await controller.getMaxZoomLevel();
      _notifyStateChanged();
    } catch (e) {
      debugPrint('CameraManager: zoom bounds refresh failed: $e');
    }
  }

  Future<double?> setZoomLevel(double zoomLevel) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return null;
    }

    if (_minZoomLevel == null || _maxZoomLevel == null) {
      await refreshZoomBounds();
    }

    final minZoom = _minZoomLevel ?? 1.0;
    final maxZoom = _maxZoomLevel ?? 1.0;
    final clampedZoom = zoomLevel.clamp(minZoom, maxZoom).toDouble();

    final completer = Completer<double?>();
    _zoomCommandQueue = _zoomCommandQueue.then((_) async {
      final currentController = _controller;
      if (currentController == null ||
          !currentController.value.isInitialized ||
          currentController != controller) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        return;
      }

      try {
        await currentController.setZoomLevel(clampedZoom);
        if (!completer.isCompleted) {
          completer.complete(clampedZoom);
        }
      } catch (e) {
        debugPrint('CameraManager: setZoomLevel failed: $e');
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }
    }).catchError((e) {
      debugPrint('CameraManager: zoom queue failed: $e');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  Future<void> setFlashEnabled(bool enabled) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      await controller.setFlashMode(
        enabled ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('CameraManager: setFlashEnabled failed: $e');
    }
  }

  Future<double?> applyScannerCameraSettings({
    double? zoomLevel,
    Offset? focusPoint,
  }) async {
    double? appliedZoom;

    if (zoomLevel != null) {
      appliedZoom = await setZoomLevel(zoomLevel);
    }

    if (focusPoint != null) {
      await setFocusPoint(focusPoint);
    }

    return appliedZoom;
  }

  Future<void> setFocusPoint(Offset? point) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || point == null) {
      return;
    }

    final normalizedPoint = Offset(
      point.dx.clamp(0.0, 1.0).toDouble(),
      point.dy.clamp(0.0, 1.0).toDouble(),
    );

    try {
      await controller.setFocusMode(FocusMode.auto);
    } catch (_) {}

    try {
      await controller.setExposureMode(ExposureMode.auto);
    } catch (_) {}

    try {
      await controller.setFocusPoint(normalizedPoint);
    } catch (e) {
      debugPrint('CameraManager: setFocusPoint failed: $e');
    }

    try {
      await controller.setExposurePoint(normalizedPoint);
    } catch (e) {
      debugPrint('CameraManager: setExposurePoint failed: $e');
    }
  }

  Future<void> _disposeController(CameraController? controller) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.dispose();
    } catch (e) {
      debugPrint('CameraManager: controller dispose failed: $e');
    }
  }

  void _notifyStateChanged() {
    if (!hasListeners) {
      return;
    }

    notifyListeners();
  }
}
