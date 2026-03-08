import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/navigation/navigation_service.dart';
// import '../../data/models/diagnosis_model.dart';

class PremiumViewModel with ChangeNotifier {
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  
  // Subscription features data
  final List<PremiumFeature> features = [
    PremiumFeature(
      title: 'Unlimited plant identifications',
      isIncludedInPro: true,
      isIncludedInBasic: true,
    ),
    PremiumFeature(
      title: 'Unlimited health diagnoses', 
      isIncludedInPro: true,
      isIncludedInBasic: true,
    ),
    PremiumFeature(
      title: 'No annoying ads',
      isIncludedInPro: true,
      isIncludedInBasic: false,
    ),
    PremiumFeature(
      title: 'Access all premium features',
      isIncludedInPro: true,
      isIncludedInBasic: false,
    ),
  ];

  // Handle subscription purchase
  Future<void> purchaseSubscription(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Implement subscription purchase logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Navigate back or show success message
      final navigationService = context.read<NavigationService>();
      navigationService.pop();
      
    } catch (error) {
      // Handle error
      print('Subscription error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class PremiumFeature {
  final String title;
  final bool isIncludedInPro;
  final bool isIncludedInBasic;

  PremiumFeature({
    required this.title,
    required this.isIncludedInPro,
    required this.isIncludedInBasic,
  });
}