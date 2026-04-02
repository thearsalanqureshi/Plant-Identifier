import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../data/services/scanner_service.dart';
import '../data/services/camera_manager.dart';
import '../data/services/analytics_service.dart';

class ScannerViewModel with ChangeNotifier {
  final ScannerService _scannerService;
   final CameraManager _cameraManager = CameraManager();
  
  CameraController? _cameraController;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  String _currentMode = 'identify';
  String _error = '';
  double _cameraOpacity = 0.0; 
   bool _mounted = true;

  ScannerViewModel(this._scannerService);
    @override
  void dispose() {
    _mounted = false; // MARK AS DISPOSED
    super.dispose();
  }

 double get cameraOpacity => _cameraOpacity;

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isFlashOn => _isFlashOn;
  bool get isCameraInitialized => _isCameraInitialized;
  bool get isInitializing => _isInitializing;
  String get currentMode => _currentMode;
  String get error => _error;


   Future<bool> initializeCamera() async {
    debugPrint('📸 ScannerViewModel: initializeCamera() called');
    
    if (_isInitializing || _isCameraInitialized) {
      debugPrint('📸 Already initializing or initialized, skipping');
      return _isCameraInitialized;
    }
    
    _isInitializing = true;
     _safeNotifyListeners();

    try {
      debugPrint('📸 Requesting camera from CameraManager...');
      _cameraController = await _cameraManager.getCamera(forLightMeter: false);
       
      // CHECK IF STILL MOUNTED BEFORE CONTINUING
      if (!_mounted) return false;

      if (_cameraController == null) {
        _error = 'Camera not available';
        _isInitializing = false;
        debugPrint('❌ CameraManager returned null');

     
         // Log camera error
      AnalyticsService.logCameraError(
        errorType: 'camera_not_available',
        errorDetail: 'CameraManager returned null',
      );


          _safeNotifyListeners();
        return false;
      }
      
      _isCameraInitialized = true;
      _isInitializing = false;
      _cameraOpacity = 1.0;
      
      debugPrint('✅ Scanner camera initialized successfully');
       _safeNotifyListeners();
      return true;
      
    } catch (e) {
      // CHECK IF STILL MOUNTED
      if (!_mounted) return false;

      _error = 'Camera setup failed: ${e.toString()}';
      _isInitializing = false;
      debugPrint('❌ Scanner camera initialization error: $e');


       // Log camera error
    AnalyticsService.logCameraError(
      errorType: 'initialization_failed',
      errorDetail: e.toString(),
    );

       _safeNotifyListeners();
      return false;
    }
  }

  void _safeNotifyListeners() {

    // ADD CHECK FOR MOUNTED STATE
    if (!_mounted || !hasListeners) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (hasListeners) {
      notifyListeners();
    }
  });
  }


  // Flash toggle
  Future<void> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
       _safeNotifyListeners();
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }


Future<File?> captureImage() async {
  debugPrint('📸 CAPTURE IMAGE STARTED');
  debugPrint('📸📸📸 CAPTURE IMAGE CALLED - START OF FLOW');
   debugPrint('📸 ScannerViewModel: captureImage() called');


  if (!_mounted) {
      debugPrint('❌ ViewModel not mounted, skipping capture');
      return null;
    }

  if (_cameraController == null || !_cameraController!.value.isInitialized) {
    debugPrint('❌ Camera not ready');


   // Log camera error
    AnalyticsService.logCameraError(
      errorType: 'camera_not_ready',
      errorDetail: 'Camera controller not initialized',
    );


    throw Exception('Camera not ready');
  }

  try {
    debugPrint('📸 Taking picture...');
    final xFile = await _cameraController!.takePicture();
    debugPrint('📸 Picture taken: ${xFile.path}');


     // CHECK IF STILL MOUNTED
      if (!_mounted) return null;
     debugPrint('📸 Picture taken: ${xFile.path}');


    // CRITICAL: Convert and verify file
    final File? imageFile = await _scannerService.convertToFile(xFile);
    
    if (imageFile == null) {
      debugPrint('❌❌❌ CONVERT TO FILE RETURNED NULL');


     // Log camera error
      AnalyticsService.logCameraError(
        errorType: 'file_conversion_failed',
        errorDetail: 'convertToFile returned null',
      );
    
      return null;
    }
    
    
    // VERIFY FILE EXISTS
    final exists = await imageFile.exists();
    debugPrint('📸 File conversion: ${exists ? "SUCCESS" : "FAILED"}');
    debugPrint('📸 File path: ${imageFile.path}');
    debugPrint('📸 File size: ${await imageFile.length()} bytes');
    
    if (!exists) {
      debugPrint('❌❌❌ CAPTURED FILE DOES NOT EXIST ON DISK');


     // Log camera error
      AnalyticsService.logCameraError(
        errorType: 'file_not_found',
        errorDetail: 'Captured file does not exist on disk',
      );

      return null;
    }
    
    debugPrint('✅✅✅ CAPTURE IMAGE COMPLETE - READY FOR NAVIGATION');


     // Log camera usage
      AnalyticsService.logCameraUsed(
        source: 'camera',
        mode: _currentMode,
      );


    return imageFile;
    
  } catch (e, stackTrace) {
    debugPrint('💥 CAPTURE ERROR: $e');
    debugPrint('Stack trace: $stackTrace');



    // Log camera error
    AnalyticsService.logCameraError(
      errorType: 'capture_failed',
      errorDetail: e.toString(),
    );
   

   
    // SAFE STATE UPDATE WITH MOUNTED CHECK
     if (_mounted) {
      Future.microtask(() {
          if (_mounted) {
        _error = 'Capture failed: $e';
         _safeNotifyListeners();
          }
      });
     }
    rethrow;
  }
}

  // Gallery pick
  Future<File?> pickImageFromGallery() async {
    debugPrint('🖼️ PICK FROM GALLERY STARTED');
     if (!_mounted)  {
       debugPrint('❌ ViewModel not mounted, skipping gallery pick');
     
     return null;
     }


    try {
       debugPrint('🖼️ Opening gallery...');
      final xFile = await _scannerService.pickImageFromGallery();
     
       if (!_mounted) return null;
     
       if (xFile == null) {
         debugPrint('❌ No image selected from gallery');
      return null;
    }
         debugPrint('🖼️ Image selected: ${xFile.path}');

           // Convert to File
    final File? imageFile = await _scannerService.convertToFile(xFile);


      if (imageFile == null) {
      debugPrint('❌❌❌ CONVERT TO FILE RETURNED NULL');
      return null;
    }
    
    // Verify file exists
    final exists = await imageFile.exists();
    debugPrint('🖼️ File conversion: ${exists ? "SUCCESS" : "FAILED"}');
    debugPrint('🖼️ File path: ${imageFile.path}');
    debugPrint('🖼️ File size: ${await imageFile.length()} bytes');
    
    if (!exists) {
      debugPrint('❌❌❌ GALLERY FILE DOES NOT EXIST ON DISK');
      return null;
    }
    
    debugPrint('✅✅✅ GALLERY PICK COMPLETE - READY FOR NAVIGATION');
    
    // Log gallery usage
    AnalyticsService.logCameraUsed(
      source: 'gallery',
      mode: _currentMode,
    );
    
    return imageFile;
    
  } catch (e, stackTrace) {
    debugPrint('💥 GALLERY PICK ERROR: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Safe state update with mounted check
    if (_mounted) {
      Future.microtask(() {
        if (_mounted) {
          _error = 'Gallery pick failed: $e';
          _safeNotifyListeners();
        }
      });
    }
    rethrow;
  }
}

  

  // Mode setting - FIXED: Use safe notify
  void setMode(String mode) {

    if (!_mounted) return;

    if (_currentMode != mode) {
      _currentMode = mode;
       _safeNotifyListeners();
    }
  }

  Future<void> disposeCamera() async {
    debugPrint('📸 ScannerViewModel: disposeCamera() called');


    // Mark as unmounted first
    _mounted = false;
    
    // Release camera back to manager
    _cameraManager.releaseCamera();
    
    // Clear local state
    _cameraController = null;
    _isCameraInitialized = false;
    _isFlashOn = false;
    _isInitializing = false;
    
    debugPrint('✅ Scanner camera disposed via CameraManager');
    
  }
  
  // OPTIONAL: If you need to check camera status
  bool isCameraAvailable() {
    return _cameraController != null && _isCameraInitialized;
  }
}