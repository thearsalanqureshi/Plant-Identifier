import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraManager {
  static final CameraManager _instance = CameraManager._internal();
  factory CameraManager() => _instance;
  CameraManager._internal();

  CameraController? _controller;
  int _activeUsers = 0;
  bool _isDisposing = false;

  Future<CameraController?> getCamera({bool forLightMeter = false}) async {
    debugPrint('📸 CameraManager: Request for ${forLightMeter ? "Light Meter" : "Scanner"} (Users: $_activeUsers)');
    
    if (_isDisposing) {
      debugPrint('📸 CameraManager: Currently disposing, please wait');
      await Future.delayed(Duration(milliseconds: 500));
      return await getCamera(forLightMeter: forLightMeter);
    }

    try {
      // Check permission
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
        if (!status.isGranted) return null;
      }

      // Get cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      final rearCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // If no controller exists, create one
      if (_controller == null) {
        debugPrint('📸 CameraManager: Creating new controller');
        _controller = CameraController(
          rearCamera,
          forLightMeter ? ResolutionPreset.low : ResolutionPreset.medium,
          enableAudio: false,
        );
        
        await _controller!.initialize();
        debugPrint('📸 CameraManager: Controller initialized for ${forLightMeter ? "Light Meter" : "Scanner"}');
      }

      _activeUsers++;
      debugPrint('📸 CameraManager: Camera assigned (Users: $_activeUsers)');
      return _controller;

    } catch (e) {
      debugPrint('📸 CameraManager: Error: $e');
      return null;
    }
  }

  void releaseCamera() {
    if (_activeUsers > 0) _activeUsers--;
    debugPrint('📸 CameraManager: Camera released (Users: $_activeUsers)');
    
    // Auto-dispose if no users
    if (_activeUsers == 0) {
      _autoDispose();
    }
  }

  Future<void> _autoDispose() async {
    _isDisposing = true;
    debugPrint('📸 CameraManager: Auto-disposing (no users)');
    
    await Future.delayed(Duration(seconds: 1)); // Wait a bit
    
    if (_activeUsers == 0 && _controller != null) {
      try {
        await _controller!.dispose();
        _controller = null;
        debugPrint('📸 CameraManager: Controller disposed');
      } catch (e) {
        debugPrint('📸 CameraManager: Dispose error: $e');
      }
    }
    
    _isDisposing = false;
  }

  Future<void> forceDispose() async {
    debugPrint('📸 CameraManager: Force disposing');
    _activeUsers = 0;
    await _controller?.dispose();
    _controller = null;
  }
}