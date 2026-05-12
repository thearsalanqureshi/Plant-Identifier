import 'dart:async';
import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../data/models/history_model.dart';
import '../data/services/analytics_service.dart';
import '../data/services/camera_manager.dart';
import '../data/services/history_service.dart';

class LightMeterViewModel with ChangeNotifier {
  final CameraManager _cameraManager = CameraManager();
  final HistoryService _historyService = HistoryService();

  bool _isDisposed = false;
  bool _cameraSessionAttached = false;
  bool _isInitialized = false;
  bool _isMeasuring = false;
  bool _isContinuous = false;
  int _cameraLifecycleToken = 0;
  double _luxValue = 0.0;
  String _errorMessage = '';

  LightMeterViewModel() {
    _cameraManager.addListener(_onCameraManagerChanged);
  }

  double get luxValue => _luxValue;
  bool get isMeasuring => _isMeasuring;
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _cameraManager.isInitializing;
  String get errorMessage => _errorMessage;
  CameraController? get cameraController => _cameraManager.controller;

  void _onCameraManagerChanged() {
    if (_isDisposed) {
      return;
    }

    if (_cameraSessionAttached) {
      final controllerReady = _cameraManager.hasController;
      if (_isInitialized != controllerReady) {
        _isInitialized = controllerReady;
        if (controllerReady) {
          _errorMessage = '';
        }
      }
    }

    _safeNotifyListeners();
  }

  Future<void> initialize() async {
    developer.log('LightMeterViewModel: initialize() called', name: 'LIGHT_METER');

    if (_isDisposed) {
      return;
    }

    if (_isInitialized &&
        cameraController != null &&
        cameraController!.value.isInitialized) {
      return;
    }

    _errorMessage = '';
    _isInitialized = false;
    _cameraLifecycleToken++;
    final int requestToken = _cameraLifecycleToken;
    _safeNotifyListeners();

    bool acquiredNewSession = false;

    try {
      final controller = _cameraSessionAttached
          ? await _cameraManager.ensureCameraReady(forLightMeter: true)
          : await _cameraManager.acquireCamera(forLightMeter: true);

      acquiredNewSession = !_cameraSessionAttached && controller != null;

      if (_isDisposed || requestToken != _cameraLifecycleToken) {
        if (acquiredNewSession) {
          await _cameraManager.releaseCamera();
        }
        return;
      }

      if (controller == null || !controller.value.isInitialized) {
        _errorMessage = _cameraManager.lastError ??
            'Camera not available. Please check permissions.';
        _isInitialized = false;
        developer.log('LightMeter: camera acquisition failed', name: 'LIGHT_METER');

        AnalyticsService.logCameraError(
          errorType: 'camera_not_available',
          errorDetail: _errorMessage,
        );

        _safeNotifyListeners();
        return;
      }

      _cameraSessionAttached = true;
      _isInitialized = true;
      _errorMessage = '';
      developer.log('LightMeter: camera acquired successfully', name: 'LIGHT_METER');
      _safeNotifyListeners();
    } catch (e) {
      if (_isDisposed || requestToken != _cameraLifecycleToken) {
        return;
      }

      _errorMessage = 'Camera error: $e';
      _isInitialized = false;
      developer.log('LightMeter initialization error: $e', name: 'LIGHT_METER');

      AnalyticsService.logCameraError(
        errorType: 'initialization_failed',
        errorDetail: e.toString(),
      );

      if (acquiredNewSession) {
        await _cameraManager.releaseCamera();
      }

      _safeNotifyListeners();
    }
  }

  Future<void> startContinuousMeasurement() async {
    if (!_isInitialized) return;

    developer.log('Starting continuous measurement', name: 'LIGHT_METER');
    _isMeasuring = true;
    _isContinuous = true;
    _safeNotifyListeners();

    _simulateLightMeasurement();
  }

  Future<void> takeSingleMeasurement() async {
    if (!_isInitialized) return;

    developer.log('Taking single measurement', name: 'LIGHT_METER');
    _isMeasuring = true;
    _safeNotifyListeners();

    final startTime = DateTime.now();

    await Future.delayed(const Duration(seconds: 2));

    _luxValue = 500 + (DateTime.now().millisecond % 9000).toDouble();
    _isMeasuring = false;

    final processingTime = DateTime.now().difference(startTime).inMilliseconds;
    AnalyticsService.logProcessingComplete(
      mode: 'light',
      success: true,
      processingTime: processingTime,
    );
    developer.log('Analytics: light measurement processing logged', name: 'LIGHT_METER');

    final lightStatus = getLightStatus();
    AnalyticsService.logLightMeasured(
      luxValue: _luxValue,
      lightStatus: lightStatus,
    );
    developer.log(
      'Analytics: Light measured - ${_luxValue.round()} LUX ($lightStatus)',
      name: 'LIGHT_METER',
    );

    _safeNotifyListeners();

    AnalyticsService.logResultViewed(
      resultType: 'light',
      mode: 'light',
    );
    developer.log('Analytics: light result viewed logged', name: 'LIGHT_METER');

    await _saveToScanHistory();
  }

  void stopMeasurement() {
    developer.log('Stopping measurement', name: 'LIGHT_METER');
    _isMeasuring = false;
    _isContinuous = false;
    _safeNotifyListeners();
  }

  void resetMeasurement() {
    developer.log('Resetting measurement', name: 'LIGHT_METER');
    stopMeasurement();
    _luxValue = 0.0;
    _safeNotifyListeners();
  }

  void _simulateLightMeasurement() {
    if (!_isContinuous) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (_isContinuous && !_isDisposed) {
        _luxValue = 500 + (DateTime.now().millisecond % 9000).toDouble();
        _safeNotifyListeners();
        _simulateLightMeasurement();
      }
    });
  }

  String getLightStatus() {
    if (_luxValue >= 1000 && _luxValue <= 10000) return 'Optimal';
    if (_luxValue < 1000) return 'Low';
    return 'High';
  }

  Color getStatusColor() {
    if (_luxValue >= 1000 && _luxValue <= 10000) return Colors.green;
    if (_luxValue < 1000) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    developer.log('LightMeterViewModel: dispose() - releasing camera listener', name: 'LIGHT_METER');
    _isDisposed = true;
    _cameraLifecycleToken++;
    _cameraManager.removeListener(_onCameraManagerChanged);
    _isContinuous = false;
    _isMeasuring = false;

    if (_cameraSessionAttached) {
      unawaited(_cameraManager.releaseCamera());
      _cameraSessionAttached = false;
    }

    developer.log('LightMeterViewModel: camera listener removed', name: 'LIGHT_METER');
    super.dispose();
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

  Future<void> _saveToScanHistory() async {
    try {
      final scan = ScanHistory(
        id: 'light_${DateTime.now().millisecondsSinceEpoch}',
        type: 'light',
        plantName: 'Light Measurement',
        timestamp: DateTime.now(),
        imagePath: null,
        isSaved: false,
        hasAbnormality: _luxValue < 1000 || _luxValue > 10000,
        resultData: {
          'luxValue': _luxValue,
          'lightStatus': getLightStatus(),
          'optimalRange': '1000-10000 LUX',
          'measurementTime': DateTime.now().toIso8601String(),
        },
      );

      await _historyService.saveScan(scan);
      developer.log('Light measurement saved: ${_luxValue.round()} LUX', name: 'LIGHT_METER');
    } catch (e) {
      developer.log('Error saving light measurement: $e', name: 'LIGHT_METER');
    }
  }
}
