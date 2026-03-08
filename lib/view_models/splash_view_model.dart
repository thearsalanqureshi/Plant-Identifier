import 'package:flutter/foundation.dart';
import '../data/services/analytics_service.dart';
import 'dart:developer' as developer; 

class SplashViewModel with ChangeNotifier {
  bool _isLoading = true;
  double _progressValue = 0.0;
   DateTime? _launchStartTime;

  bool get isLoading => _isLoading;
  double get progressValue => _progressValue;

  // Simulate app initialization process
  Future<void> initializeApp() async {
   _launchStartTime = DateTime.now();

    await Future.delayed(Duration.zero);
    _progressValue = 0.0;
    notifyListeners();

     // Simulate loading steps with progress updates
    await _simulateLoadingStep("Initializing...", 0.3);
    await _simulateLoadingStep("Loading assets...", 0.6);
    await _simulateLoadingStep("Preparing app...", 1.0);
    
    _isLoading = false;
    notifyListeners();
  }
  
 Future<void> _simulateLoadingStep(String step, double progress) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Each step takes 800ms
    _progressValue = progress;
    notifyListeners();
  }
  
  // Control navigation speed separately
  Future<void> navigateAfterDelay() async {

 // Calculate launch duration
    final launchDuration = _launchStartTime != null 
      ? DateTime.now().difference(_launchStartTime!).inMilliseconds
      : null;

       debugPrint('📊 SPLASH: Calling analytics, duration: $launchDuration ms');
        developer.log('📊 SPLASH: Analytics called', name: 'ANALYTICS');
    // Log app launch to analytics
    AnalyticsService.logAppLaunch(launchDuration: launchDuration);


    await Future.delayed(const Duration(seconds: 2)); // Reduced from 3 to 2 seconds
  }
}