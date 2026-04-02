import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/services/analytics_service.dart';

class AppPermissions {

 static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions() async {
    debugPrint('🔐 Requesting multiple permissions...');
   
    try {
    if (Platform.isAndroid) {
     final androidInfo = await DeviceInfoPlugin().androidInfo;
  final isAndroid13Plus = androidInfo.version.sdkInt >= 33;
  
  final permissions = [
    Permission.camera,
    if (!isAndroid13Plus) Permission.storage,
    if (isAndroid13Plus) Permission.photos,
  ];

      final statuses = await  permissions.request();
       


      // Log each permission result
      for (final permission in statuses.keys) {
        final status = statuses[permission]!;
        if (status.isDenied || status.isPermanentlyDenied) {
          final permissionType = permission.toString().split('.').last;
          AnalyticsService.logPermissionDenied(
            permissionType: permissionType,
          );
          debugPrint('📊 Analytics: $permissionType permission denied');
        }
      }
      
      return statuses;
    }

    
    /*
     // For iOS or other platforms
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      AnalyticsService.logPermissionDenied(
        permissionType: 'camera',
      );
      debugPrint('📊 Analytics: Camera permission denied');
    }
    */


    return {Permission.camera: PermissionStatus.granted};
  } catch (e) {
    debugPrint('❌ Multiple permissions request error: $e');
    return {};
  }
}

  static Future<bool> requestCameraPermission() async {
      debugPrint('🔐 Requesting camera permission...');


       try {
    final status = await Permission.camera.request();
     debugPrint('🔐 Camera permission status: $status');

      if (status.isDenied || status.isPermanentlyDenied) {
     
     
      // Log permission denied
      AnalyticsService.logPermissionDenied(
        permissionType: 'camera',
      );
      
      debugPrint('📊 Analytics: Camera permission denied');
  
    } else if (status.isGranted) {
      debugPrint('✅ Camera permission granted');
    }

    return status.isGranted;
  } catch (e) {
    debugPrint('❌ Permission request error: $e');
    
    // ✅ NEW: Log permission error
    AnalyticsService.logPermissionDenied(
      permissionType: 'camera',
    );
    
    return false;
  }
  }



  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }
   static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
  
  static Future<bool> shouldShowRequestPermissionRationale() async {
    final status = await Permission.camera.status;
    return status.isDenied && !status.isPermanentlyDenied;
  }
}