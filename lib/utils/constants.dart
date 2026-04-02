class AppConstants {
  // Design constants
  static const double designWidth = 375;
  static const double designHeight = 812;
  
  // Animation durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  
  // Storage keys
  static const String settingsBox = 'settings';
  static const String plantsBox = 'plants';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Asset paths
  static const String appLogoSvg = 'assets/images/app_logo.svg';
  static const String appLogoPng = 'assets/images/app_logo.png'; // fallback
  
  // Onboarding assets
  static const String onboarding1Svg = 'assets/images/onboarding_1_4x.png';
  static const String onboarding2Svg = 'assets/images/onboarding_2_4x.png';
  static const String onboarding3Svg = 'assets/images/onboarding_3_4x.png';

 // Home Screen Assets
  static const String locationIcon = 'assets/icons/ic_location.svg';
  static const String editIcon = 'assets/icons/ic_edit.svg';
  static const String premiumIcon = 'assets/icons/ic_premium.svg';
  static const String identifyIcon = 'assets/icons/ic_identify.svg';
  static const String diagnoseIcon = 'assets/icons/ic_diagnose.svg';
  static const String waterCalculatorIcon = 'assets/icons/ic_water_calc.svg';
  static const String lightMeterIcon = 'assets/icons/ic_light_meter.svg';
  static const String identifyBackground = 'assets/images/bg_identify.svg';
  static const String diagnoseBackground = 'assets/images/bg_diagnose.svg';
  static const String waterCalculatorBackground = 'assets/images/bg_water_calc.svg';
  static const String lightMeterBackground = 'assets/images/bg_light_meter.svg';
  

  // Bottom Navigation Assets 
  static const String homeIcon = 'assets/icons/ic_home.svg';
  static const String recordIcon = 'assets/icons/ic_record.svg';
  static const String settingsIcon = 'assets/icons/ic_settings.svg';
  static const String homeActiveIcon = 'assets/icons/ic_home_active.svg';
  static const String recordActiveIcon = 'assets/icons/ic_record_active.svg';
  static const String settingsActiveIcon = 'assets/icons/ic_settings_active.svg';
  
  // Default Address
  static const String defaultLocationName = 'Office';
  static const String defaultAddress = '164 A Dc Colony Gujranwala Punjab';

  // Language Assets
  static const String backIcon = 'assets/icons/back_icon.svg';
  static const String tickIcon = 'assets/icons/tick_icon.svg';
  static const String checkedIcon = 'assets/icons/ic_checked.svg';    
  static const String uncheckedIcon = 'assets/icons/ic_unchecked.svg';
  
  // Language Codes
  static const String defaultLanguage = 'en';

  // API Configuration
  static const String geminiApiKey = String.fromEnvironment("MY_API_KEY");
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  // App Configuration
  static const String appName = 'Plant Identifier';
  static const String appVersion = '1.0.0';

  // Scanner Assets
  static const String cancelIcon = 'assets/icons/ic_cancel.svg';
  static const String flashOnIcon = 'assets/icons/ic_flash_on.svg';
  static const String flashOffIcon = 'assets/icons/ic_flash_off.svg';
  static const String galleryIcon = 'assets/icons/ic_gallery.svg';
  static const String cameraIcon = 'assets/icons/ic_camera.svg';
  // static const String tickIcon = 'assets/icons/ic_tick.svg';

  // Scanner Strings
  static const String scanPlant = 'Scan Plant';
  static const String scanDisease = 'Scan Disease';

  // Icons for Plant Result Screen
  static const String shareIcon = 'assets/icons/ic_share.svg';
  static const String temperatureIcon = 'assets/icons/ic_temperature.svg';
  static const String lightIcon = 'assets/icons/ic_sunlight.svg';
  static const String soilIcon = 'assets/icons/ic_soil.svg';
  static const String humidityIcon = 'assets/icons/ic_humidity.svg';
  static const String wateringIcon = 'assets/icons/ic_watering.svg';
  static const String fertilizingIcon = 'assets/icons/ic_fertilizing.svg';
  static const String warningIcon = 'assets/icons/ic_warning.svg';

  // Processing Screen
static const String processing = 'assets/icons/ic_processing.svg';

static const String waterResultImage = 'assets/images/water_result.svg';
static const String waterResultImagePng = 'assets/images/water_result.png';

// Light Meter Screen
static const String lightMeterStep1 = 'assets/images/light_meter_step_1.png';
static const String lightMeterStep2 = 'assets/images/light_meter_step_2.png';
static const String lightMeterStep3 = 'assets/images/light_meter_step_3.png';


 // Settings Screen Assets
  static const String languageIcon = 'assets/icons/ic_language.png';
  static const String rateIcon = 'assets/icons/ic_rate.png';
  static const String privacyIcon = 'assets/icons/ic_privacy.png';
  static const String rightArrow = 'assets/icons/ic_right_arrow.svg';
  static const String feedbackIcon = 'assets/icons/ic_feedback.png';
  

 // Rating Screen Assets
  static const String starFilled = 'assets/icons/star_filled.svg';
  static const String starOutline = 'assets/icons/star_outline.svg';


 // Premium Banner Assets
  static const String premiumLeft = 'assets/images/premium_left.png';
  static const String premiumRight = 'assets/images/premium_right.png';


  // Premium Screen Assets
  static const String closeIcon = 'assets/icons/ic_close.png';
  static const String premiumCrown = 'assets/images/premium_crown.png';
  static const String dividerLine = 'assets/images/divider_line.png';
  static const String tickGreen = 'assets/icons/ic_tick_green.svg';
  static const String lockIcon = 'assets/icons/ic_lock.svg';
}

class AppStrings {
  static const String appName = 'Plant Identifier';
  static const String splashLoading = 'Loading...';
//  static const String next = 'Next';
//  static const String letsGo = 'Let\'s Go';
  
  // Onboarding content
//  static const String onboarding1Title = 'Identify your plant';
  static const String onboarding1Body = 'Scan plants with AI to get instant identification and detailed information about any plant species.';
  
  static const String onboarding2Title = 'Diagnose your plant';
  static const String onboarding2Body = 'Detect plant diseases and get expert care tips to keep your green friends healthy and thriving.';
  
  static const String onboarding3Title = 'Plant Care Made Easy';
  static const String onboarding3Body = 'Save plant history, get personalized tips, and set reminders to never miss a watering day.';

  static const String selectLanguage = 'Select Language';
  static const String english = 'English';
  static const String urdu = 'Urdu';
  static const String german = 'German';
  static const String french = 'French';
  static const String arabic = 'Arabic';
  static const String spanish = 'Spanish';
  static const String japanese = 'Japanese';
  static const String korean = 'Korean';
  
  // Home Screen Texts
  static const String appBarTitle = 'Green Scan';
  static const String pro = 'PRO';
  
  static const String identify = 'Identify';
  static const String identifySubtitle = 'Recognize any Plant';
  
  static const String diagnose = 'Diagnose';
  static const String diagnoseSubtitle = 'Check Your Plant\'s Health';
  
   // Water Calculation Assets
  static const String waterProgress1 = 'assets/icons/water_progress_1.svg';
  static const String waterProgress2 = 'assets/icons/water_progress_2.svg';
  static const String waterProgress3 = 'assets/icons/water_progress_3.svg';
  static const String waterResultImage = 'assets/images/water_result.svg';
  static const String backIcon = 'assets/icons/back_icon.svg';
  
  // Water Calculation Questions
  static const List<String> plantLocations = [
    'Indoor, Close To Window',
    'Indoor, In A Shaded Corner',
    'Outdoor, Full Sun',
    'Outdoor, Partial Shade',
  ];
  
  static const List<String> temperatureOptions = [
    'Very Cold (Below 5°C / 41°F)',
    'Cold (Below 15°C / 59°F)',
    'Moderate (15°C - 25°C / 59°F - 77°F)',
    'Warm (25°C - 30°C / 77°F - 86°F)',
    'Hot (Above 30°C / 86°F)',
  ];
  
  static const List<String> wateringFrequencyOptions = [
    'Daily',
    'Every 2-3 Days',
    'Once A Week',
    'Every two Weeks',
    'Rarely / When Dry',
  ];

  // Bottom Navigation
 // static const String home = 'Home';
//  static const String history = 'History';
//  static const String settings = 'Settings';

  // Scanner Screen Texts
  static const String identifyingPlant = 'Identifying Plant';
  static const String diagnosingPlant = 'Diagnosing Plant';
  static const String smartFastAccurate = 'Smart, fast, and accurate plant ID';
  static const String spottingDiseases = 'Spotting possible diseases and issues';
  static const String takePhoto = 'Take Photo';
  static const String retake = 'Retake';
  static const String usePhoto = 'Use Photo';

// Water Calculation Strings
  static const String waterCalculator = 'Water Calculator';
  static const String whereKeepPlant = 'Where do you intend to keep the plant?';
  static const String currentTemperature = 'What\'s the current temperature?';
  static const String wateringFrequency = 'How often do you water?';
  static const String continueText = 'Continue';
  static const String plantWaterNeed = 'Plant Water Need';
  static const String waterGuide = 'Use this guide to ensure your plant stays happy and well-watered';
  static const String thankYou = 'Thank You';
  static const String waterAmount = '76 ML';



  static const String waterCalculatorSubtitle = 'Optimize Watering for your plant';
  static const String lightMeter = 'Light Meter';
  static const String lightMeterSubtitle = 'Measure optimal Lightning';

}

// Language Model
class Language {
  final String code;
  final String name;
  final String nativeName;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}