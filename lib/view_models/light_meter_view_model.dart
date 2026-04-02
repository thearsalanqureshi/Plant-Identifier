import 'dart:developer' as developer;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../data/models/history_model.dart';
import '../data/services/analytics_service.dart';
import '../data/services/history_service.dart';
import '../data/services/camera_manager.dart'; 

class LightMeterViewModel with ChangeNotifier {
  final CameraManager _cameraManager = CameraManager(); // CHANGE THIS
  final HistoryService _historyService = HistoryService();
  
  CameraController? _cameraController; // KEEP THIS
  double _luxValue = 0.0;
  bool _isMeasuring = false;
  bool _isInitialized = false;
  String _errorMessage = '';
  bool _isContinuous = false;

  double get luxValue => _luxValue;
  bool get isMeasuring => _isMeasuring;
  bool get isInitialized => _isInitialized;
  String get errorMessage => _errorMessage;
  CameraController? get cameraController => _cameraController; // UPDATE GETTER

  Future<void> initialize() async {
    developer.log('💡 LightMeterViewModel: initialize() called', name: 'LIGHT_METER');
    
    try {
      // Get camera from shared manager
      _cameraController = await _cameraManager.getCamera(forLightMeter: true);
      developer.log('💡 CameraManager returned controller: ${_cameraController != null}', name: 'LIGHT_METER');
      
      if (_cameraController == null) {
        _errorMessage = 'Camera not available. Please check permissions.';
        _isInitialized = false;
        developer.log('❌ LightMeter: Camera acquisition failed', name: 'LIGHT_METER');
      } else {
        _isInitialized = true;
        developer.log('✅ LightMeter: Camera acquired successfully', name: 'LIGHT_METER');
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Camera error: $e';
      _isInitialized = false;
      developer.log('💥 LightMeter initialization error: $e', name: 'LIGHT_METER');
      notifyListeners();
    }
  }

  Future<void> startContinuousMeasurement() async {
    if (!_isInitialized) return;
    
    developer.log('💡 Starting continuous measurement', name: 'LIGHT_METER');
    _isMeasuring = true;
    _isContinuous = true;
    notifyListeners();
    
    // Simulate measurement (replace with actual sensor logic if available)
    _simulateLightMeasurement();
  }

  Future<void> takeSingleMeasurement() async {
    if (!_isInitialized) return;
    
    developer.log('💡 Taking single measurement', name: 'LIGHT_METER');
    _isMeasuring = true;
    notifyListeners();

      final startTime = DateTime.now(); // Track processing time
    
    // Simulate 2-second measurement
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate realistic LUX value (500-9500)
    _luxValue = 500 + (DateTime.now().millisecond % 9000).toDouble();
    _isMeasuring = false;
    
    
  // Log processing success
  final processingTime = DateTime.now().difference(startTime).inMilliseconds;
  AnalyticsService.logProcessingComplete(
    mode: 'light',
    success: true,
    processingTime: processingTime,
  );
  developer.log('📊 Analytics: Light measurement processing logged', name: 'LIGHT_METER');
  


 //  Log light measured
  final lightStatus = getLightStatus();
  AnalyticsService.logLightMeasured(
    luxValue: _luxValue,
    lightStatus: lightStatus,
  );
  developer.log('📊 Analytics: Light measured - ${_luxValue.round()} LUX ($lightStatus)', name: 'LIGHT_METER');

  developer.log('📊 Measurement result: ${_luxValue.round()} LUX', name: 'LIGHT_METER');


    notifyListeners();

     // Log result viewed
  AnalyticsService.logResultViewed(
    resultType: 'light',
    mode: 'light',
  );
  developer.log('📊 Analytics: Light result viewed logged', name: 'LIGHT_METER');


    // Save to history
    await _saveToScanHistory();
  }

  void stopMeasurement() {
    developer.log('💡 Stopping measurement', name: 'LIGHT_METER');
    _isMeasuring = false;
    _isContinuous = false;
    notifyListeners();
  }

  void resetMeasurement() {
    developer.log('💡 Resetting measurement', name: 'LIGHT_METER');
    stopMeasurement();
    _luxValue = 0.0;
    notifyListeners();
  }

  void _simulateLightMeasurement() {
    if (!_isContinuous) return;
    
    // Update LUX value every second
    Future.delayed(Duration(seconds: 1), () {
      if (_isContinuous) {
        _luxValue = 500 + (DateTime.now().millisecond % 9000).toDouble();
        notifyListeners();
        _simulateLightMeasurement(); // Continue
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
    developer.log('💡 LightMeterViewModel: dispose() - Releasing camera', name: 'LIGHT_METER');
    
    // Release camera back to manager
    _cameraManager.releaseCamera();
    _cameraController = null;
    
    developer.log('✅ LightMeterViewModel: Camera released', name: 'LIGHT_METER');
    super.dispose();
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
      developer.log('✅ Light measurement saved: ${_luxValue.round()} LUX', name: 'LIGHT_METER');
      
    } catch (e) {
      developer.log('❌ Error saving light measurement: $e', name: 'LIGHT_METER');
    }
  }
}