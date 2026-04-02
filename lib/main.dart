import 'dart:ui';
import 'dart:io';
// import 'app.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/history_model.dart';
import 'app/app.dart';
import 'data/models/history_model_adapter.dart';
import 'data/models/plant_model.dart';
import 'data/models/plant_model_adapter.dart';
import 'data/services/notification_service.dart';
import 'data/services/version_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; 
import 'package:provider/provider.dart';
import 'view_models/language_view_model.dart'; 
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show debugPrint;


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📱 Background message: ${message.messageId}');
}

void main() async {
  
 if (Platform.isAndroid) {
    debugPrint('📱 Disabling Impeller for camera compatibility');
  }

  print('🚀 APP START - SIMPLE HIVE SETUP');
   developer.log('🎯 MAIN START', name: 'APP');
  
  WidgetsFlutterBinding.ensureInitialized();

   // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('🔥 Firebase Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
   debugPrint('🔥 Firebase Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  debugPrint('🔥 Firebase App ID: ${DefaultFirebaseOptions.currentPlatform.appId}');
  developer.log('🔥 Firebase Initialized', 
    name: 'FIREBASE', 
    error: 'Project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  

   await NotificationService.initialize();

    // Setup message handlers
 // NotificationService.setupMessageHandlers();

   // Enable analytics with debug mode
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
 // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  // Its just for Test - Force debug test event
  await FirebaseAnalytics.instance.logEvent(
    name: 'debug_test',
    parameters: {'test': 'firebase_connection'},
  );
  
  debugPrint('🔥 Debug test event sent to Firebase');
  developer.log('🔥 Debug event sent', name: 'ANALYTICS');


  debugPrint('🔥 Setting up Crashlytics...');
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  debugPrint('✅ Crashlytics ready - All crashes will be auto-tracked');


await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);


debugPrint('🧪 Testing Crashlytics integration...');
FirebaseCrashlytics.instance.log("App started successfully");

  
  try {
  await Hive.initFlutter();
  
  // Register adapters 
  Hive.registerAdapter(ScanHistoryAdapter());
  Hive.registerAdapter(PlantAdapter());
  
  // TRY to open boxes normally first
  try {
    await Hive.openBox<ScanHistory>('scanHistory');
    await Hive.openBox<Plant>('plants');
    print('✅ Hive Ready - Existing data loaded');
  } catch (e) {
    print('⚠️ Hive corruption detected: $e');
    print('🧹 Cleaning corrupted boxes...');
    
    await Hive.close();
    await Hive.deleteBoxFromDisk('scanHistory');
    await Hive.deleteBoxFromDisk('plants');
    
    await Hive.initFlutter();
    Hive.registerAdapter(ScanHistoryAdapter());
    Hive.registerAdapter(PlantAdapter());
    
    await Hive.openBox<ScanHistory>('scanHistory');
    await Hive.openBox<Plant>('plants');
    
    print('✅ Hive recovered from corruption');
  }
  
} catch (e) {
  print('⚠️ Hive corruption detected: $e');
  print('🧹 Cleaning corrupted boxes...');
  
  try {
    await Hive.close();
  } catch (_) {} // Ignore close errors
  
  try {
    await Hive.deleteBoxFromDisk('scanHistory');
  } catch (_) {} // Ignore if doesn't exist
  
  try {
    await Hive.deleteBoxFromDisk('plants');
  } catch (_) {} // Ignore if doesn't exist
  
  // Re-initialize fresh
  await Hive.initFlutter();
  
  print('✅ Hive recovered from corruption');
}

/*
WidgetsBinding.instance.addPostFrameCallback((_) {
  _checkAppVersion();
});
*/

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageViewModel(),
      child: const PlantIdentifierApp(),
    ),
  );
    

/*
void _checkAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  debugPrint('📱 App Version: ${packageInfo.version}+${packageInfo.buildNumber}');
}
*/

WidgetsBinding.instance.addPostFrameCallback((_) async {
    final needsUpdate = await VersionService.checkForceUpdate();
    if (needsUpdate) {
      _showForceUpdateDialog();
    }
  });
}

void _showForceUpdateDialog() {
  // Show blocking dialog that forces user to update
  // Cannot proceed without updating
}