import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Event names following Firebase Analytics conventions
class AnalyticsEvents {
  static const String appLaunch = 'app_launch';
  static const String featureSelected = 'feature_selected';
   static const String cameraUsed = 'camera_used';
  static const String processingComplete = 'processing_complete';
  static const String resultViewed = 'result_viewed';
  static const String plantIdentified = 'plant_identified';
  static const String plantSaved = 'plant_saved';
  static const String plantRemoved = 'plant_removed';
  static const String diagnosisViewed = 'diagnosis_viewed';
  static const String waterCalculated = 'water_calculated';
  static const String lightMeasured = 'light_measured';
  static const String screenView = 'screen_view';
  static const String tabChanged = 'tab_changed';
  static const String settingsChanged = 'settings_changed';
  static const String appRated = 'app_rated';
  static const String apiError = 'api_error';
  static const String cameraError = 'camera_error';
  static const String permissionDenied = 'permission_denied';
  static const String apiPerformance = 'api_performance';
  static const String jsonParsing = 'json_parsing';
  static const String apiRetry = 'api_retry';
  static const String fallbackUsed = 'fallback_used';
  static const String paramErrorType = 'error_type';
  static const String paramStatusCode = 'status_code';
  static const String paramErrorDetail = 'error_detail';
  static const String paramImageSize = 'image_size_kb';
  static const String paramResponseLength = 'response_length';
  static const String paramRawLength = 'raw_length';
  static const String paramCleanLength = 'clean_length';
  static const String paramParseTime = 'parse_time_ms';
  static const String paramAttemptNumber = 'attempt_number';
  static const String paramRetryReason = 'retry_reason';
  static const String paramFallbackType = 'fallback_type';
  static const String paramApiCallType = 'api_call_type';
  static const String paramFeature = 'feature';
  

  
  // Parameter names
  static const String paramFeatureId = 'feature_id';
  static const String paramFeatureName = 'feature_name';
  static const String paramLaunchDuration = 'launch_duration_ms';
  static const String paramPlatform = 'platform';
  static const String paramSource = 'source'; // 'camera' or 'gallery'
  static const String paramMode = 'mode'; // 'identify', 'diagnose', 'water', 'light'
  static const String paramSuccess = 'success';
  static const String paramResultType = 'result_type'; // 'identification', 'diagnosis', 'water', 'light'
  static const String paramError = 'error';
  static const String paramProcessingTime = 'processing_time_ms';
  static const String paramPlantName = 'plant_name';
  static const String paramDiseaseName = 'disease_name';
  static const String paramSeverity = 'severity';
  static const String paramWaterAmount = 'water_amount';
  static const String paramLuxValue = 'lux_value';
  static const String paramLightStatus = 'light_status';
  static const String paramScreenName = 'screen_name';
  static const String paramTabName = 'tab_name';
  static const String paramSettingName = 'setting_name';
  static const String paramSettingValue = 'setting_value';
  static const String paramRatingValue = 'rating_value';
}

/// Firebase Analytics service wrapper
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Log app launch event
  static Future<void> logAppLaunch({int? launchDuration}) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.appLaunch,
        parameters: {
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
          if (launchDuration != null) 
            AnalyticsEvents.paramLaunchDuration: launchDuration,
        },
      );
      debugPrint('📊 Analytics: App launch logged');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log app launch - $e');
    }
  }
  
  /// Log feature selection event
  static Future<void> logFeatureSelected({
    required String featureId,
    required String featureName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.featureSelected,
        parameters: {
          AnalyticsEvents.paramFeatureId: featureId,
          AnalyticsEvents.paramFeatureName: featureName,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Feature "$featureName" ($featureId) selected');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log feature selection - $e');
    }
  }


 /// Log camera usage event
  static Future<void> logCameraUsed({
    required String source,
    required String mode,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.cameraUsed,
        parameters: {
          AnalyticsEvents.paramSource: source,
          AnalyticsEvents.paramMode: mode,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Camera used - source:$source, mode:$mode');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log camera used - $e');
    }
  }
  
  /// Log processing completion event
  static Future<void> logProcessingComplete({
    required String mode,
    required bool success,
    String? error,
    int? processingTime,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.processingComplete,
        parameters: {
          AnalyticsEvents.paramMode: mode,
          AnalyticsEvents.paramSuccess: success ? 1 : 0,
          if (error != null) AnalyticsEvents.paramError: error,
          if (processingTime != null) AnalyticsEvents.paramProcessingTime: processingTime,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Processing complete - mode:$mode, success:$success');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log processing complete - $e');
    }
  }
  
  /// Log result viewed event
  static Future<void> logResultViewed({
    required String resultType,
    required String mode,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.resultViewed,
        parameters: {
          AnalyticsEvents.paramResultType: resultType,
          AnalyticsEvents.paramMode: mode,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Result viewed - type:$resultType, mode:$mode');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log result viewed - $e');
    }
  }


/// Log plant identification event
  static Future<void> logPlantIdentified({
    required String plantName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.plantIdentified,
        parameters: {
          AnalyticsEvents.paramPlantName: plantName,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Plant "$plantName" identified');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log plant identified - $e');
    }
  }

  /// Log plant saved event
  static Future<void> logPlantSaved({
    required String plantName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.plantSaved,
        parameters: {
          AnalyticsEvents.paramPlantName: plantName,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Plant "$plantName" saved to My Plants');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log plant saved - $e');
    }
  }

  /// Log plant removed event
  static Future<void> logPlantRemoved({
    required String plantName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.plantRemoved,
        parameters: {
          AnalyticsEvents.paramPlantName: plantName,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Plant "$plantName" removed from My Plants');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log plant removed - $e');
    }
  }

  /// Log diagnosis viewed event
  static Future<void> logDiagnosisViewed({
    required String plantName,
    required String diseaseName,
    required String severity,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.diagnosisViewed,
        parameters: {
          AnalyticsEvents.paramPlantName: plantName,
          AnalyticsEvents.paramDiseaseName: diseaseName,
          AnalyticsEvents.paramSeverity: severity,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Diagnosis viewed - $plantName, $diseaseName ($severity)');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log diagnosis viewed - $e');
    }
  }

  /// Log water calculation event
  static Future<void> logWaterCalculated({
    required String plantName,
    required String waterAmount,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.waterCalculated,
        parameters: {
          AnalyticsEvents.paramPlantName: plantName,
          AnalyticsEvents.paramWaterAmount: waterAmount,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Water calculated - $plantName: $waterAmount');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log water calculated - $e');
    }
  }

  /// Log light measurement event
  static Future<void> logLightMeasured({
    required double luxValue,
    required String lightStatus,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.lightMeasured,
        parameters: {
          AnalyticsEvents.paramLuxValue: luxValue,
          AnalyticsEvents.paramLightStatus: lightStatus,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Light measured - ${luxValue.round()} LUX ($lightStatus)');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log light measured - $e');
    }
  }

 /// Log screen view event
  static Future<void> logScreenView({
    required String screenName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.screenView,
        parameters: {
          AnalyticsEvents.paramScreenName: screenName,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Screen "$screenName" viewed');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log screen view - $e');
    }
  }

  /// Log tab changed event
  static Future<void> logTabChanged({
    required String tabName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.tabChanged,
        parameters: {
          AnalyticsEvents.paramTabName: tabName,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Tab changed to "$tabName"');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log tab changed - $e');
    }
  }

  /// Log settings changed event
  static Future<void> logSettingsChanged({
    required String settingName,
    required String settingValue,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.settingsChanged,
        parameters: {
          AnalyticsEvents.paramSettingName: settingName,
          AnalyticsEvents.paramSettingValue: settingValue,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Setting "$settingName" changed to "$settingValue"');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log settings changed - $e');
    }
  }

  /// Log app rated event
  static Future<void> logAppRated({
    required int ratingValue,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.appRated,
        parameters: {
          AnalyticsEvents.paramRatingValue: ratingValue,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: App rated $ratingValue stars');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log app rated - $e');
    }
  }

  
  /// Log API error event
  static Future<void> logApiError({
    required String errorType,
    int? statusCode,
    String? errorDetail,
    required String feature,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.apiError,
        parameters: {
          AnalyticsEvents.paramErrorType: errorType,
          AnalyticsEvents.paramFeature: feature,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
          if (statusCode != null) AnalyticsEvents.paramStatusCode: statusCode,
          if (errorDetail != null && errorDetail.isNotEmpty) 
            AnalyticsEvents.paramErrorDetail: errorDetail.substring(0, min(100, errorDetail.length)),
        },
      );
      debugPrint('📊 Analytics: API error - $errorType ($feature)');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log API error - $e');
    }
  }

  /// Log camera error event
  static Future<void> logCameraError({
    required String errorType,
    String? errorDetail,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.cameraError,
        parameters: {
          AnalyticsEvents.paramErrorType: errorType,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
          if (errorDetail != null && errorDetail.isNotEmpty) 
            AnalyticsEvents.paramErrorDetail: errorDetail.substring(0, min(100, errorDetail.length)),
        },
      );
      debugPrint('📊 Analytics: Camera error - $errorType');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log camera error - $e');
    }
  }

  /// Log permission denied event
  static Future<void> logPermissionDenied({
    required String permissionType,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.permissionDenied,
        parameters: {
          AnalyticsEvents.paramErrorType: permissionType,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Permission denied - $permissionType');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log permission denied - $e');
    }
  }

  /// Log API performance event
  static Future<void> logApiPerformance({
    required String apiCallType,
    required int imageSize,
    required int responseLength,
    required int processingTime,
    required String feature,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.apiPerformance,
        parameters: {
          AnalyticsEvents.paramApiCallType: apiCallType,
          AnalyticsEvents.paramImageSize: imageSize,
          AnalyticsEvents.paramResponseLength: responseLength,
          AnalyticsEvents.paramProcessingTime: processingTime,
          AnalyticsEvents.paramFeature: feature,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: API performance - $apiCallType (${imageSize}KB, ${responseLength} chars, ${processingTime}ms)');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log API performance - $e');
    }
  }

  /// Log JSON parsing event
  static Future<void> logJsonParsing({
    required int rawLength,
    required int cleanLength,
    required int parseTime,
    required bool success,
    String? errorDetail,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.jsonParsing,
        parameters: {
          AnalyticsEvents.paramRawLength: rawLength,
          AnalyticsEvents.paramCleanLength: cleanLength,
          AnalyticsEvents.paramParseTime: parseTime,
          AnalyticsEvents.paramSuccess: success ? 1 : 0,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
          if (errorDetail != null && !success) 
            AnalyticsEvents.paramErrorDetail: errorDetail.substring(0, min(100, errorDetail.length)),
        },
      );
      debugPrint('📊 Analytics: JSON parsing - ${success ? "Success" : "Failed"} (${parseTime}ms, raw:${rawLength}, clean:${cleanLength})');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log JSON parsing - $e');
    }
  }

  /// Log API retry event
  static Future<void> logApiRetry({
    required int attemptNumber,
    required String retryReason,
    required String feature,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.apiRetry,
        parameters: {
          AnalyticsEvents.paramAttemptNumber: attemptNumber,
          AnalyticsEvents.paramRetryReason: retryReason,
          AnalyticsEvents.paramFeature: feature,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: API retry attempt $attemptNumber - $retryReason ($feature)');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log API retry - $e');
    }
  }

  /// Log fallback used event
  static Future<void> logFallbackUsed({
    required String fallbackType,
    required String fallbackReason,
    required String feature,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.fallbackUsed,
        parameters: {
          AnalyticsEvents.paramFallbackType: fallbackType,
          AnalyticsEvents.paramErrorDetail: fallbackReason,
          AnalyticsEvents.paramFeature: feature,
          AnalyticsEvents.paramPlatform: defaultTargetPlatform.name,
        },
      );
      debugPrint('📊 Analytics: Fallback used - $fallbackType ($feature): $fallbackReason');
    } catch (e) {
      debugPrint('📊 Analytics Error: Failed to log fallback used - $e');
    }
  }



  
  /// Get user ID for debugging (optional)
  static Future<String?> getAnalyticsUserId() async {
  final sessionId = await _analytics.getSessionId();
  return sessionId?.toString(); 
  }
}