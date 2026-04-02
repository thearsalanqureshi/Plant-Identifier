import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
    Locale('de'),
    Locale('fr'),
    Locale('ar'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// Application name displayed in splash screen and app bar
  ///
  /// In en, this message translates to:
  /// **'Plant Identifier'**
  String get app_name;

  /// Title text on splash screen
  ///
  /// In en, this message translates to:
  /// **'Plant Identifier'**
  String get splash_title;

  /// Onboarding screen 1 title (alternative key)
  ///
  /// In en, this message translates to:
  /// **'Identify your plant'**
  String get onboarding1Title;

  /// Onboarding screen 1 body text (alternative key)
  ///
  /// In en, this message translates to:
  /// **'Scan plants with AI to get instant identification and detailed information about any plant species.'**
  String get onboarding1Body;

  /// Onboarding screen 2 title (alternative key)
  ///
  /// In en, this message translates to:
  /// **'Diagnose your plant'**
  String get onboarding2Title;

  /// Onboarding screen 2 body text (alternative key)
  ///
  /// In en, this message translates to:
  /// **'Detect plant diseases and get expert care tips to keep your green friends healthy and thriving.'**
  String get onboarding2Body;

  /// Onboarding screen 3 title (alternative key)
  ///
  /// In en, this message translates to:
  /// **'Plant Care Made Easy'**
  String get onboarding3Title;

  /// Onboarding screen 3 body text (alternative key)
  ///
  /// In en, this message translates to:
  /// **'Save plant history, get personalized tips, and set reminders to never miss a watering day.'**
  String get onboarding3Body;

  /// Next button on onboarding (alternative key)
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Let's Go button on final onboarding screen (alternative key)
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go'**
  String get letsGo;

  /// Title for plant identification during onboarding
  ///
  /// In en, this message translates to:
  /// **'Identifying Plant'**
  String get onboarding_identifying;

  /// Title for plant diagnosis during onboarding
  ///
  /// In en, this message translates to:
  /// **'Diagnosing Plant'**
  String get onboarding_diagnosing;

  /// Title for water calculation during onboarding
  ///
  /// In en, this message translates to:
  /// **'Calculating Water Needs'**
  String get onboarding_calculating_water;

  /// Default processing title during onboarding
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get onboarding_processing;

  /// Subtitle for identification mode
  ///
  /// In en, this message translates to:
  /// **'Smart, fast, and accurate plant ID'**
  String get onboarding_subtitle_identify;

  /// Subtitle for diagnosis mode
  ///
  /// In en, this message translates to:
  /// **'Spotting possible diseases and issues'**
  String get onboarding_subtitle_diagnose;

  /// Subtitle for water calculation mode
  ///
  /// In en, this message translates to:
  /// **'Analyzing plant and environment...'**
  String get onboarding_subtitle_water;

  /// Default loading subtitle
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get onboarding_subtitle_default;

  /// Onboarding screen 1 title
  ///
  /// In en, this message translates to:
  /// **'Identify your plant'**
  String get onboarding_title_identify;

  /// Onboarding screen 1 body text
  ///
  /// In en, this message translates to:
  /// **'Scan plants with AI to get instant identification and detailed information about any plant species.'**
  String get onboarding_body_identify;

  /// Onboarding screen 2 title
  ///
  /// In en, this message translates to:
  /// **'Diagnose your plant'**
  String get onboarding_title_diagnose;

  /// Onboarding screen 2 body text
  ///
  /// In en, this message translates to:
  /// **'Detect plant diseases and get expert care tips to keep your green friends healthy and thriving.'**
  String get onboarding_body_diagnose;

  /// Onboarding screen 3 title
  ///
  /// In en, this message translates to:
  /// **'Plant Care Made Easy'**
  String get onboarding_title_care;

  /// Onboarding screen 3 body text
  ///
  /// In en, this message translates to:
  /// **'Save plant history, get personalized tips, and set reminders to never miss a watering day.'**
  String get onboarding_body_care;

  /// Next button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// Let's Go button on final onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go'**
  String get onboarding_lets_go;

  /// Home screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Plant Identifier'**
  String get home_title;

  /// App bar title for the main screen
  ///
  /// In en, this message translates to:
  /// **'Green Scan'**
  String get appBarTitle;

  /// Subtitle for identify feature card on home screen
  ///
  /// In en, this message translates to:
  /// **'Recognize any Plant'**
  String get home_identify_subtitle;

  /// Subtitle for diagnose feature card on home screen
  ///
  /// In en, this message translates to:
  /// **'Check Your Plant\'s Health'**
  String get home_diagnose_subtitle;

  /// Subtitle for water calculator feature card on home screen
  ///
  /// In en, this message translates to:
  /// **'Optimize Watering for your plant'**
  String get home_water_subtitle;

  /// Subtitle for light meter feature card on home screen
  ///
  /// In en, this message translates to:
  /// **'Measure optimal Lightning'**
  String get home_light_subtitle;

  /// Error message when feature is unavailable
  ///
  /// In en, this message translates to:
  /// **'Feature {featureId} not available'**
  String home_feature_not_available(String featureId);

  /// Title for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Urdu language name
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// German language name
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Japanese language name
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// Korean language name
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// Button or tab label for identify feature
  ///
  /// In en, this message translates to:
  /// **'Identify'**
  String get identify;

  /// Button or tab label for diagnose feature
  ///
  /// In en, this message translates to:
  /// **'Diagnose'**
  String get diagnose;

  /// Scanner mode indicator for plant identification
  ///
  /// In en, this message translates to:
  /// **'Identify Plant'**
  String get scanner_mode_identify;

  /// Scanner screen identify plant button/label
  ///
  /// In en, this message translates to:
  /// **'Identify Plant'**
  String get scanner_identify_plant;

  /// Scanner mode indicator for plant diagnosis
  ///
  /// In en, this message translates to:
  /// **'Diagnose Plant'**
  String get scanner_mode_diagnose;

  /// Scanner screen diagnose plant button/label
  ///
  /// In en, this message translates to:
  /// **'Diagnose Plant'**
  String get scanner_diagnose_plant;

  /// Scanner mode indicator for water calculation
  ///
  /// In en, this message translates to:
  /// **'Water Calculation'**
  String get scanner_mode_water;

  /// Scanner screen water calculation button/label
  ///
  /// In en, this message translates to:
  /// **'Water Calculation'**
  String get scanner_water_calculation;

  /// Default scanner mode text
  ///
  /// In en, this message translates to:
  /// **'Scan Mode'**
  String get scanner_mode_default;

  /// Scanner screen mode indicator
  ///
  /// In en, this message translates to:
  /// **'Scan Mode'**
  String get scanner_scan_mode;

  /// Error message when image capture fails
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image'**
  String get scanner_capture_error;

  /// Error message when gallery image pick fails
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get scanner_gallery_error;

  /// Button to take a photo in scanner
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get scanner_take_photo;

  /// Button to retake photo
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get scanner_retake;

  /// Button to use the taken photo
  ///
  /// In en, this message translates to:
  /// **'Use Photo'**
  String get scanner_use_photo;

  /// Gallery button text in preview screen
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get preview_gallery;

  /// Placeholder text when no image is selected
  ///
  /// In en, this message translates to:
  /// **'No Image'**
  String get preview_no_image;

  /// Error message when trying to proceed without selecting an image
  ///
  /// In en, this message translates to:
  /// **'Please select an image first'**
  String get preview_select_image_error;

  /// Title shown while plant identification is running
  ///
  /// In en, this message translates to:
  /// **'Identifying Plant'**
  String get processing_identify_title;

  /// Title shown while plant diagnosis is running
  ///
  /// In en, this message translates to:
  /// **'Diagnosing Plant'**
  String get processing_diagnose_title;

  /// Title shown while water calculation is running
  ///
  /// In en, this message translates to:
  /// **'Calculating Water Needs'**
  String get processing_water_title;

  /// Fallback title shown during processing
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing_generic_title;

  /// Processing screen title for identification
  ///
  /// In en, this message translates to:
  /// **'Identifying Plant'**
  String get processing_title_identify;

  /// Processing screen identifying text
  ///
  /// In en, this message translates to:
  /// **'Identifying Plant'**
  String get processing_identifying;

  /// Processing screen title for diagnosis
  ///
  /// In en, this message translates to:
  /// **'Diagnosing Plant'**
  String get processing_title_diagnose;

  /// Processing screen diagnosing text
  ///
  /// In en, this message translates to:
  /// **'Diagnosing Plant'**
  String get processing_diagnosing;

  /// Processing screen title for water calculation
  ///
  /// In en, this message translates to:
  /// **'Calculating Water Needs'**
  String get processing_title_water;

  /// Processing screen calculating water text
  ///
  /// In en, this message translates to:
  /// **'Calculating Water Needs'**
  String get processing_calculating_water;

  /// Default processing screen title
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing_title_default;

  /// Processing screen default text
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing_processing;

  /// Processing subtitle for identification
  ///
  /// In en, this message translates to:
  /// **'Smart, fast, and accurate plant ID'**
  String get processing_subtitle_identify;

  /// Processing subtitle for identification
  ///
  /// In en, this message translates to:
  /// **'Smart, fast, and accurate plant ID'**
  String get processing_smart_fast_accurate;

  /// Processing subtitle for diagnosis
  ///
  /// In en, this message translates to:
  /// **'Spotting possible diseases and issues'**
  String get processing_subtitle_diagnose;

  /// Processing subtitle for diagnosis
  ///
  /// In en, this message translates to:
  /// **'Spotting possible diseases and issues'**
  String get processing_spotting_diseases;

  /// Processing subtitle for water calculation
  ///
  /// In en, this message translates to:
  /// **'Analyzing plant and environment...'**
  String get processing_subtitle_water;

  /// Processing subtitle for water calculation
  ///
  /// In en, this message translates to:
  /// **'Analyzing plant and environment...'**
  String get processing_analyzing;

  /// Default processing subtitle
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get processing_subtitle_default;

  /// Default processing subtitle
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get processing_please_wait;

  /// Title for plant identification result screen
  ///
  /// In en, this message translates to:
  /// **'Plant Identified'**
  String get result_plant_identified;

  /// Section heading for plant description
  ///
  /// In en, this message translates to:
  /// **'About the Plant'**
  String get result_about_plant;

  /// Section heading for climate information
  ///
  /// In en, this message translates to:
  /// **'Climate Requirements'**
  String get result_climate_requirements;

  /// Label for temperature requirement
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get result_temperature;

  /// Label for light requirement
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get result_light;

  /// Label for soil requirement
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get result_soil;

  /// Label for humidity requirement
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get result_humidity;

  /// Section heading for care information
  ///
  /// In en, this message translates to:
  /// **'Care Schedule'**
  String get result_care_schedule;

  /// Label for watering schedule
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get result_watering;

  /// Label for fertilizing schedule
  ///
  /// In en, this message translates to:
  /// **'Fertilizing'**
  String get result_fertilizing;

  /// Section heading for toxicity/safety information
  ///
  /// In en, this message translates to:
  /// **'Safety Warning'**
  String get result_safety_warning;

  /// Success message when plant is saved
  ///
  /// In en, this message translates to:
  /// **'Saved to My Plants!'**
  String get result_saved_success;

  /// Success message when plant is removed
  ///
  /// In en, this message translates to:
  /// **'Removed from My Plants'**
  String get result_removed_success;

  /// Button text to save plant (inactive state)
  ///
  /// In en, this message translates to:
  /// **'Save To My Plants'**
  String get result_save_button;

  /// Button text when plant is already saved (active state)
  ///
  /// In en, this message translates to:
  /// **'Saved to My Plants'**
  String get result_saved_button;

  /// Button to start new plant identification
  ///
  /// In en, this message translates to:
  /// **'Identify Another Plant'**
  String get result_identify_another;

  /// Error title for identification result
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get result_error;

  /// Error message when plant data is missing
  ///
  /// In en, this message translates to:
  /// **'No plant data available'**
  String get result_no_data;

  /// Button to retry identification
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get result_try_again;

  /// Title for plant diagnosis result screen
  ///
  /// In en, this message translates to:
  /// **'Diagnose Result'**
  String get diagnosis_title;

  /// Title for diagnosis result screen
  ///
  /// In en, this message translates to:
  /// **'Diagnose Result'**
  String get diagnosis_result;

  /// Section heading for severity information
  ///
  /// In en, this message translates to:
  /// **'Severity Assessment'**
  String get diagnosis_severity_assessment;

  /// Label for severity level indicator
  ///
  /// In en, this message translates to:
  /// **'Severity Level'**
  String get diagnosis_severity_level;

  /// Section heading for immediate care actions
  ///
  /// In en, this message translates to:
  /// **'Immediate Actions (Next 24-48 hours)'**
  String get diagnosis_immediate_actions;

  /// Section heading for treatment information
  ///
  /// In en, this message translates to:
  /// **'Treatment Plan'**
  String get diagnosis_treatment_plan;

  /// Section heading for monitoring checklist
  ///
  /// In en, this message translates to:
  /// **'Daily Monitoring'**
  String get diagnosis_daily_monitoring;

  /// Section heading for recovery timeline
  ///
  /// In en, this message translates to:
  /// **'Expected Recovery'**
  String get diagnosis_expected_recovery;

  /// Button to start new diagnosis
  ///
  /// In en, this message translates to:
  /// **'Diagnose Another Plant'**
  String get diagnosis_diagnose_another;

  /// Button to return to home screen
  ///
  /// In en, this message translates to:
  /// **'Back To Home'**
  String get diagnosis_back_home;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Error'**
  String get diagnosis_error_title;

  /// Error title for diagnosis result
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Error'**
  String get diagnosis_error;

  /// Error message when diagnosis data is missing
  ///
  /// In en, this message translates to:
  /// **'No diagnosis data available'**
  String get diagnosis_error_no_data;

  /// Error message when diagnosis data is missing
  ///
  /// In en, this message translates to:
  /// **'No diagnosis data available'**
  String get diagnosis_no_data;

  /// Button to retry diagnosis
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get diagnosis_try_again;

  /// Title for premium subscription screen
  ///
  /// In en, this message translates to:
  /// **'Upgrade To Premium'**
  String get premium_title;

  /// Button/text for premium upgrade
  ///
  /// In en, this message translates to:
  /// **'Upgrade To Premium'**
  String get premium_upgrade;

  /// Subtitle text for premium screen
  ///
  /// In en, this message translates to:
  /// **'Experience It All — Effortless and Uninterrupted'**
  String get premium_subtitle;

  /// Premium experience description
  ///
  /// In en, this message translates to:
  /// **'Experience It All — Effortless and Uninterrupted'**
  String get premium_experience;

  /// Header for features comparison table
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get premium_features_header;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get premium_features;

  /// Column header for PRO tier
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get premium_pro_header;

  /// PRO tier label
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get premium_pro;

  /// Column header for Basic tier
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get premium_basic_header;

  /// Basic tier label
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get premium_basic;

  /// Price text for premium subscription
  ///
  /// In en, this message translates to:
  /// **'Rs 750.00/Week After Free 3-Day Trial'**
  String get premium_price;

  /// Button to start premium subscription
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get premium_start_now;

  /// Footer disclaimer text
  ///
  /// In en, this message translates to:
  /// **'Subscription will auto-renew. Cancel anytime.'**
  String get premium_footer;

  /// Title for light meter screen
  ///
  /// In en, this message translates to:
  /// **'Light Meter'**
  String get light_meter_title;

  /// Instruction text for using light meter
  ///
  /// In en, this message translates to:
  /// **'Position your phone at the intended plant placement location.'**
  String get light_meter_instruction;

  /// Label for optimal light range card
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get light_meter_optimal;

  /// Status text during measurement
  ///
  /// In en, this message translates to:
  /// **'Measuring'**
  String get light_meter_measuring;

  /// Optimal light range value
  ///
  /// In en, this message translates to:
  /// **'1000-10000 LUX'**
  String get light_meter_optimal_range;

  /// Loading text during camera initialization
  ///
  /// In en, this message translates to:
  /// **'Initializing Camera...'**
  String get light_meter_initializing;

  /// Placeholder text when camera is starting
  ///
  /// In en, this message translates to:
  /// **'Starting Camera...'**
  String get light_meter_starting;

  /// Button to take light measurement
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get light_meter_measure;

  /// Button to reset measurement
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get light_meter_reset;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Initialization Failed'**
  String get light_meter_error_title;

  /// Button to retry camera initialization
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get light_meter_retry;

  /// Title for light meter info screen
  ///
  /// In en, this message translates to:
  /// **'How To Use Light Meter?'**
  String get light_info_title;

  /// Title for light meter info screen
  ///
  /// In en, this message translates to:
  /// **'How To Use Light Meter?'**
  String get light_info_how_to_use;

  /// First instruction step
  ///
  /// In en, this message translates to:
  /// **'Keep your front camera facing the light source.'**
  String get light_info_step1;

  /// Second instruction step
  ///
  /// In en, this message translates to:
  /// **'Move phone around plant to measure light from all angles'**
  String get light_info_step2;

  /// Third instruction step
  ///
  /// In en, this message translates to:
  /// **'Check light levels at mid-day for the most accurate results'**
  String get light_info_step3;

  /// Button to close info screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get light_info_continue;

  /// Error text when instruction image fails to load
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get light_info_image_error;

  /// Title for privacy policy screen
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy_title;

  /// Title for settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// Settings option for language selection
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settings_app_language;

  /// Settings option to rate the app
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get settings_rate_us;

  /// Settings option to share the app
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get settings_share_app;

  /// Settings option to send feedback
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settings_feedback;

  /// Settings option to view privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy_policy;

  /// Error message when a feature is not available
  ///
  /// In en, this message translates to:
  /// **'Feature {featureId} not available'**
  String settings_feature_unavailable(String featureId);

  /// Error message when email cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open email. Please email us at {email}'**
  String settings_could_not_open_email(String email);

  /// Message shown when FCM token is copied
  ///
  /// In en, this message translates to:
  /// **'Token copied to clipboard'**
  String get debug_token_copied;

  /// Button text to get FCM token (debug)
  ///
  /// In en, this message translates to:
  /// **'Get FCM Token'**
  String get debug_get_token;

  /// Message shown when FCM token is copied
  ///
  /// In en, this message translates to:
  /// **'Token copied to clipboard'**
  String get settings_token_copied;

  /// Button text to get FCM token (debug)
  ///
  /// In en, this message translates to:
  /// **'Get FCM Token'**
  String get settings_get_fcm_token;

  /// Button text to test crash (debug)
  ///
  /// In en, this message translates to:
  /// **'Test Crash'**
  String get settings_test_crash;

  /// Title for water calculator feature
  ///
  /// In en, this message translates to:
  /// **'Water Calculator'**
  String get water_calculator;

  /// Button to continue to next question
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get water_continue;

  /// Question about plant location
  ///
  /// In en, this message translates to:
  /// **'Where do you intend to keep the plant?'**
  String get water_question_location;

  /// First water calculation question
  ///
  /// In en, this message translates to:
  /// **'Where do you intend to keep the plant?'**
  String get water_location_q1;

  /// Question about current temperature
  ///
  /// In en, this message translates to:
  /// **'What\'s the current temperature?'**
  String get water_question_temperature;

  /// Second water calculation question
  ///
  /// In en, this message translates to:
  /// **'What\'s the current temperature?'**
  String get water_location_q2;

  /// Question about watering frequency
  ///
  /// In en, this message translates to:
  /// **'How often do you water?'**
  String get water_question_frequency;

  /// Third water calculation question
  ///
  /// In en, this message translates to:
  /// **'How often do you water?'**
  String get water_location_q3;

  /// Option for indoor location near window
  ///
  /// In en, this message translates to:
  /// **'Indoor, Close To Window'**
  String get water_location_indoor_window;

  /// Option for indoor shaded location
  ///
  /// In en, this message translates to:
  /// **'Indoor, In A Shaded Corner'**
  String get water_location_indoor_shaded;

  /// Option for outdoor full sun location
  ///
  /// In en, this message translates to:
  /// **'Outdoor, Full Sun'**
  String get water_location_outdoor_sun;

  /// Option for outdoor partial shade location
  ///
  /// In en, this message translates to:
  /// **'Outdoor, Partial Shade'**
  String get water_location_outdoor_shade;

  /// Very cold temperature option
  ///
  /// In en, this message translates to:
  /// **'Very Cold (Below 5°C / 41°F)'**
  String get water_temperature_very_cold;

  /// Cold temperature option
  ///
  /// In en, this message translates to:
  /// **'Cold (Below 15°C / 59°F)'**
  String get water_temperature_cold;

  /// Moderate temperature option
  ///
  /// In en, this message translates to:
  /// **'Moderate (15°C - 25°C / 59°F - 77°F)'**
  String get water_temperature_moderate;

  /// Warm temperature option
  ///
  /// In en, this message translates to:
  /// **'Warm (25°C - 30°C / 77°F - 86°F)'**
  String get water_temperature_warm;

  /// Hot temperature option
  ///
  /// In en, this message translates to:
  /// **'Hot (Above 30°C / 86°F)'**
  String get water_temperature_hot;

  /// Daily watering frequency
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get water_frequency_daily;

  /// Every 2-3 days watering frequency
  ///
  /// In en, this message translates to:
  /// **'Every 2-3 Days'**
  String get water_frequency_2_3_days;

  /// Weekly watering frequency
  ///
  /// In en, this message translates to:
  /// **'Once A Week'**
  String get water_frequency_weekly;

  /// Every two weeks watering frequency
  ///
  /// In en, this message translates to:
  /// **'Every two Weeks'**
  String get water_frequency_biweekly;

  /// Rarely or when dry watering frequency
  ///
  /// In en, this message translates to:
  /// **'Rarely / When Dry'**
  String get water_frequency_rarely;

  /// Title for water calculation result screen
  ///
  /// In en, this message translates to:
  /// **'Plant Water Need'**
  String get water_result_title;

  /// Title for water calculation result screen
  ///
  /// In en, this message translates to:
  /// **'Plant Water Need'**
  String get water_plant_water_need;

  /// Section heading for watering schedule
  ///
  /// In en, this message translates to:
  /// **'Watering Schedule'**
  String get water_result_schedule;

  /// Watering schedule section title
  ///
  /// In en, this message translates to:
  /// **'Watering Schedule'**
  String get water_schedule;

  /// Label for watering frequency
  ///
  /// In en, this message translates to:
  /// **'Frequency:'**
  String get water_result_frequency_label;

  /// Frequency label
  ///
  /// In en, this message translates to:
  /// **'Frequency:'**
  String get water_frequency;

  /// Label for best watering time
  ///
  /// In en, this message translates to:
  /// **'Best Time:'**
  String get water_result_best_time_label;

  /// Best time label
  ///
  /// In en, this message translates to:
  /// **'Best Time:'**
  String get water_best_time;

  /// Section heading for care tips
  ///
  /// In en, this message translates to:
  /// **'Care Tips'**
  String get water_result_tips;

  /// Care tips section title
  ///
  /// In en, this message translates to:
  /// **'Care Tips'**
  String get water_care_tips;

  /// Button to return to home
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get water_result_thank_you;

  /// Thank you message
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get water_thank_you;

  /// Guide text on water result screen
  ///
  /// In en, this message translates to:
  /// **'Use this guide to ensure your plant stays happy and well-watered'**
  String get water_result_guide;

  /// Water amount recommendation
  ///
  /// In en, this message translates to:
  /// **'76 ML'**
  String get water_result_amount;

  /// Loading text during water calculation
  ///
  /// In en, this message translates to:
  /// **'Calculating water needs...'**
  String get water_result_loading;

  /// Loading text during water calculation
  ///
  /// In en, this message translates to:
  /// **'Calculating water needs...'**
  String get water_calculating;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Calculation Error'**
  String get water_result_error_title;

  /// Error title for water calculation
  ///
  /// In en, this message translates to:
  /// **'Calculation Error'**
  String get water_error_title;

  /// Error message when water calculation data is missing
  ///
  /// In en, this message translates to:
  /// **'No water calculation data available'**
  String get water_result_error_no_data;

  /// Error message when water data is missing
  ///
  /// In en, this message translates to:
  /// **'No water calculation data available'**
  String get water_no_data;

  /// Button to return home from error state
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get water_result_back_home;

  /// Button to return home
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get water_back_home;

  /// Title for history screen
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get history_title;

  /// Empty state title for My Plants tab
  ///
  /// In en, this message translates to:
  /// **'No Saved Plants'**
  String get history_empty_my_plants;

  /// Empty state title for History tab
  ///
  /// In en, this message translates to:
  /// **'Nothing to show'**
  String get history_empty_history;

  /// Empty state description for My Plants tab
  ///
  /// In en, this message translates to:
  /// **'Save plants from scan history to see them here'**
  String get history_empty_my_plants_desc;

  /// Empty state description for History tab
  ///
  /// In en, this message translates to:
  /// **'All your scans will appear here'**
  String get history_empty_history_desc;

  /// Dialog title for light measurement history item
  ///
  /// In en, this message translates to:
  /// **'Light Measurement Result'**
  String get history_light_dialog_title;

  /// Label for light level value
  ///
  /// In en, this message translates to:
  /// **'Light Level:'**
  String get history_light_level;

  /// Unit for light measurement
  ///
  /// In en, this message translates to:
  /// **'LUX'**
  String get history_lux_unit;

  /// Label for light status
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get history_status;

  /// Unknown status text
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get history_status_unknown;

  /// Label for optimal light range
  ///
  /// In en, this message translates to:
  /// **'Optimal Range:'**
  String get history_optimal_range;

  /// Label for timestamp
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get history_time;

  /// Button to close dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get history_close;

  /// Timestamp for very recent scans
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get history_timestamp_just_now;

  /// Suffix for minutes ago
  ///
  /// In en, this message translates to:
  /// **'min ago'**
  String get history_timestamp_min_ago;

  /// Suffix for hours ago
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get history_timestamp_hours_ago;

  /// Suffix for days ago
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get history_timestamp_days_ago;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete ?'**
  String get history_delete_title;

  /// Confirmation message for delete action
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ?'**
  String get history_delete_confirmation;

  /// Button to confirm deletion
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get history_delete_button;

  /// Button to cancel deletion
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get history_cancel_button;

  /// Action sheet option to remove from saved plants
  ///
  /// In en, this message translates to:
  /// **'Remove from My Plants'**
  String get history_remove_from_my_plants;

  /// Action sheet option to save to plants
  ///
  /// In en, this message translates to:
  /// **'Save to My Plants'**
  String get history_save_to_my_plants;

  /// Share option in action sheet
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get history_share;

  /// Home tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottom_nav_home;

  /// History tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get bottom_nav_history;

  /// Settings tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottom_nav_settings;

  /// Message when language is changed
  ///
  /// In en, this message translates to:
  /// **'Language updated to {language}'**
  String language_updated(String language);

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// Urdu language name
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get language_urdu;

  /// German language name
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get language_german;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get language_french;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get language_arabic;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get language_spanish;

  /// Japanese language name
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get language_japanese;

  /// Korean language name
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get language_korean;

  /// Title for language selection screen app bar
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get widget_language_app_bar_title;

  /// Label for severity level indicator
  ///
  /// In en, this message translates to:
  /// **'Severity Level'**
  String get widget_severity_level;

  /// Section heading for severity assessment
  ///
  /// In en, this message translates to:
  /// **'Severity Assessment'**
  String get widget_severity_assessment;

  /// Message when no plant is found in image
  ///
  /// In en, this message translates to:
  /// **'No plant detected in image'**
  String get widget_no_plant_detected;

  /// Badge label for treatment items
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get widget_treatment_badge;

  /// Bullet point separator character
  ///
  /// In en, this message translates to:
  /// **'•'**
  String get widget_bullet_separator;

  /// Severity level badge text - mild
  ///
  /// In en, this message translates to:
  /// **'MILD'**
  String get widget_severity_mild;

  /// Severity level badge text - moderate
  ///
  /// In en, this message translates to:
  /// **'MODERATE'**
  String get widget_severity_moderate;

  /// Severity level badge text - severe
  ///
  /// In en, this message translates to:
  /// **'SEVERE'**
  String get widget_severity_severe;

  /// Severity level badge text - critical
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get widget_severity_critical;

  /// Severity level badge text - healthy
  ///
  /// In en, this message translates to:
  /// **'HEALTHY'**
  String get widget_severity_healthy;

  /// Premium banner text with line break
  ///
  /// In en, this message translates to:
  /// **'Explore Premium Features\nFor Free'**
  String get widget_premium_banner_text;

  /// Button text on premium banner
  ///
  /// In en, this message translates to:
  /// **'Upgrade To Pro'**
  String get widget_premium_banner_button;

  /// Premium card text with line break
  ///
  /// In en, this message translates to:
  /// **'Explore Premium Features\nFor Free'**
  String get widget_premium_card_text;

  /// Button text on premium card
  ///
  /// In en, this message translates to:
  /// **'Upgrade To Pro'**
  String get widget_premium_card_button;

  /// Text on Pro/Premium button
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get widget_pro_button;

  /// Title for rating bottom sheet with line break
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience With\nOur App'**
  String get widget_rating_title;

  /// Description text for rating sheet with line break
  ///
  /// In en, this message translates to:
  /// **'Please rate your experience and help us\nimprove. Thank You'**
  String get widget_rating_description;

  /// Button to submit rating
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get widget_rating_submit;

  /// Thank you message with placeholder for rating value
  ///
  /// In en, this message translates to:
  /// **'Thank you for your {rating} star rating!'**
  String widget_rating_thank_you(int rating);

  /// Badge text for identification scan type
  ///
  /// In en, this message translates to:
  /// **'IDENTIFIED'**
  String get widget_history_badge_identified;

  /// Badge text for diagnosis scan type
  ///
  /// In en, this message translates to:
  /// **'DIAGNOSED'**
  String get widget_history_badge_diagnosed;

  /// Badge text for water calculation scan type
  ///
  /// In en, this message translates to:
  /// **'CALCULATED'**
  String get widget_history_badge_calculated;

  /// Badge text for light meter scan type
  ///
  /// In en, this message translates to:
  /// **'MEASURED'**
  String get widget_history_badge_measured;

  /// Timestamp text for very recent scans
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get widget_history_timestamp_just_now;

  /// Suffix for minutes ago
  ///
  /// In en, this message translates to:
  /// **'min ago'**
  String get widget_history_timestamp_min_ago;

  /// Suffix for hours ago
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get widget_history_timestamp_hours_ago;

  /// Suffix for days ago
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get widget_history_timestamp_days_ago;

  /// Tab label for My Plants section
  ///
  /// In en, this message translates to:
  /// **'My Plants'**
  String get widget_history_tab_my_plants;

  /// Tab label for History section
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get widget_history_tab_history;

  /// Opening parenthesis for count display
  ///
  /// In en, this message translates to:
  /// **'('**
  String get widget_history_tab_open_paren;

  /// Closing parenthesis for count display
  ///
  /// In en, this message translates to:
  /// **')'**
  String get widget_history_tab_close_paren;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
