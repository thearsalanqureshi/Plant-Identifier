import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../data/models/onboarding_model.dart';
import '../utils/constants.dart';

class OnboardingViewModel with ChangeNotifier {
  final List<OnboardingModel> _onboardingPages = [
    OnboardingModel(
       titleKey: 'onboarding_title_identify',
       descriptionKey: 'onboarding_body_identify',
      imagePath: AppConstants.onboarding1Svg,
      buttonTextKey: 'onboarding_next',
    ),
    OnboardingModel(
      titleKey: 'onboarding_title_diagnose',
     descriptionKey: 'onboarding_body_diagnose',
      imagePath: AppConstants.onboarding2Svg,
      buttonTextKey: 'onboarding_next',
    ),
    OnboardingModel(
       titleKey: 'onboarding_title_care',
      descriptionKey: 'onboarding_body_care',
      imagePath: AppConstants.onboarding3Svg,
      buttonTextKey:'onboarding_lets_go',
    ),
  ];

  int _currentPageIndex = 0;
  
  List<OnboardingModel> get onboardingPages => _onboardingPages;
  int get currentPageIndex => _currentPageIndex;
  int get totalPages => _onboardingPages.length;
  bool get isLastPage => _currentPageIndex == _onboardingPages.length - 1;

  void goToNextPage() {
    if (_currentPageIndex < _onboardingPages.length - 1) {
      _currentPageIndex++;
      notifyListeners();
    }
  }

  void goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
    }
  }

  void setCurrentPage(int index) {
    if (index >= 0 && index < _onboardingPages.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final settingsBox = await Hive.openBox(AppConstants.settingsBox);
    await settingsBox.put(AppConstants.onboardingCompletedKey, true);
  }

  // Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final settingsBox = await Hive.openBox(AppConstants.settingsBox);
    return settingsBox.get(AppConstants.onboardingCompletedKey, defaultValue: false);
  }
}