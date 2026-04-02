import 'package:flutter/foundation.dart';
import '../utils/app_types.dart';
import '../utils/constants.dart';
import '../data/services/analytics_service.dart';
import 'dart:developer' as developer; 

class HomeFeature {
  final String id;
  final String title;
  final String subtitle;
  final CardType type;
  final CardSize size;

  const HomeFeature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.size,
  });
}

class HomeViewModel with ChangeNotifier {
  String _locationName = AppConstants.defaultLocationName;
  String _address = AppConstants.defaultAddress;
  
  String get locationName => _locationName;
  String get address => _address;
  
  
   // Feature definitions with analytics tracking
  final List<HomeFeature> _largeFeatures = const [
    HomeFeature(
      id: 'identify',
      title: AppStrings.identify,
      subtitle: AppStrings.identifySubtitle,
      type: CardType.identify,
      size: CardSize.large,
    ),
    HomeFeature(
      id: 'diagnose',
      title: AppStrings.diagnose,
      subtitle: AppStrings.diagnoseSubtitle,
      type: CardType.diagnose,
      size: CardSize.large,
    ),
  ];

  final List<HomeFeature> _smallFeatures = const [
    HomeFeature(
      id: 'water',
      title: AppStrings.waterCalculator,
      subtitle: AppStrings.waterCalculatorSubtitle,
      type: CardType.water,
      size: CardSize.small,
    ),
    HomeFeature(
      id: 'light',
      title: AppStrings.lightMeter,
      subtitle: AppStrings.lightMeterSubtitle,
      type: CardType.light,
      size: CardSize.small,
    ),
  ];

  List<HomeFeature> get largeFeatures => _largeFeatures;
  List<HomeFeature> get smallFeatures => _smallFeatures;

  
  
void updateAddress(String newLocationName, String newAddress) {
  try {
    // Basic validation
    if (newLocationName.isEmpty || newAddress.isEmpty) {
      debugPrint('Address fields cannot be empty');
      return;
    }
    
    _locationName = newLocationName;
    _address = newAddress;
    notifyListeners();
    
  } catch (e) {
    debugPrint('Error updating address: $e');
  }
}

/// Business logic for premium feature access
void handlePremiumAccess() {
  // Pure business logic - no navigation
  debugPrint('Premium feature business logic executed');


  // Log premium access attempt (optional)
    AnalyticsService.logFeatureSelected(
      featureId: 'premium',
      featureName: 'Premium Access',
    ); 
}

/// Pure business logic for feature identification
String validateFeatureAccess(String featureId) {
  debugPrint('📊 HOME: validateFeatureAccess called for $featureId');
    developer.log('📊 HOME: Feature access validated', name: 'ANALYTICS');
    
 // Log the feature selection in analytics
    final feature = [..._largeFeatures, ..._smallFeatures]
        .firstWhere((f) => f.id == featureId, orElse: () => _largeFeatures.first);
    
    AnalyticsService.logFeatureSelected(
      featureId: featureId,
      featureName: feature.title,
    );
    
    debugPrint('📊 Feature analytics logged for: $featureId');

  // Check if user has access, return feature ID if valid
  return featureId;
}

  /// Address editing logic
  void editAddress() {
    // Handle address editing business logic
    debugPrint('Edit address initiated');
  }
}