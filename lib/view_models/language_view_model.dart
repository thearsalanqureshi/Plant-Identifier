import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/language_model.dart';
import '../data/services/analytics_service.dart';
import '../utils/constants.dart';

class LanguageViewModel with ChangeNotifier {
  final List<LanguageModel> _supportedLanguages = const [
    LanguageModel(code: 'en', name: 'English'),
    LanguageModel(code: 'ur', name: 'Urdu'),
    LanguageModel(code: 'de', name: 'German'),
    LanguageModel(code: 'fr', name: 'French'),
    LanguageModel(code: 'ar', name: 'Arabic'),
    LanguageModel(code: 'es', name: 'Spanish'),
    LanguageModel(code: 'ja', name: 'Japanese'),
    LanguageModel(code: 'ko', name: 'Korean'),
  ];

    Locale _currentLocale = const Locale('en', 'US');
    Locale get currentLocale => _currentLocale;


  LanguageModel _selectedLanguage = const LanguageModel(
    code: 'en', 
    name: 'English', 
  //  nativeName: 'English'
  );

   LanguageModel get selectedLanguage => _selectedLanguage;
  List<LanguageModel> get supportedLanguages => _supportedLanguages;

//  LanguageModel get selectedLanguage => _selectedLanguage;
  LanguageViewModel() {
    _loadSelectedLanguage();
  }


static const String _defaultLanguage = 'en';
static bool _isInitialized = false;

  Future<void> _loadSelectedLanguage() async {
  
   if (_isInitialized) return;
  
    try {
    final settingsBox = await Hive.openBox(AppConstants.settingsBox);
    final savedLanguageCode = settingsBox.get('selected_language', 
        defaultValue: AppConstants.defaultLanguage);
    
    final savedLanguage = _supportedLanguages.firstWhere(
      (lang) => lang.code == savedLanguageCode,
      orElse: () => _supportedLanguages.first,
    );
    
    _selectedLanguage = savedLanguage;
     _currentLocale = Locale(savedLanguage.code); //_getCountryCode(savedLanguage.code));
    notifyListeners();
     debugPrint('🌐 Loaded language: ${savedLanguage.code}');

  }  catch (e) {
      debugPrint('❌ Error loading language: $e');
      _currentLocale = const Locale('en');
      _selectedLanguage = _supportedLanguages.first;
    }
  }

/*
String _getCountryCode(String languageCode) {
    switch (languageCode) {
      case 'en': return 'US';
      case 'ur': return 'PK';
      case 'de': return 'DE';
      case 'fr': return 'FR';
      case 'ar': return 'SA';
      case 'es': return 'ES';
      case 'ja': return 'JP';
      case 'ko': return 'KR';
      default: return 'US';
    }
  }
  */


  void selectLanguage(LanguageModel language) {
    _selectedLanguage = language;
    notifyListeners();
    debugPrint('🌐 Selected language: ${language.code}');
  }

  Future<void> saveLanguageSelection() async {
     try {
    final settingsBox = await Hive.openBox(AppConstants.settingsBox);
    await settingsBox.put('selected_language', _selectedLanguage.code);

    // Update the locale AFTER saving
  _currentLocale = Locale(_selectedLanguage.code);   // _getCountryCode(_selectedLanguage.code));
    notifyListeners();


   // Log settings changed
  AnalyticsService.logSettingsChanged(
    settingName: 'language',
    settingValue: _selectedLanguage.code,
  );
  debugPrint('📊 Analytics: Language changed to "${_selectedLanguage.name}" (${_selectedLanguage.code})');
   debugPrint('🌐 App locale updated to: ${_currentLocale.languageCode}');
  } catch (e) {
      debugPrint('❌ Error saving language: $e');
    }
  }

  bool isSelected(LanguageModel language) {
   return _selectedLanguage.code == language.code;
  }
}