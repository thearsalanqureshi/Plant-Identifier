import 'package:flutter/material.dart';

import 'package:plant_identifier_app/data/services/scanner_service.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'navigation/app_routes.dart';
import '../data/services/camera_manager.dart';
import 'navigation/navigation_service.dart';

import '../view_models/splash_view_model.dart';
import '../view_models/onboarding_view_model.dart';
import '../view_models/home_view_model.dart';
import '../view_models/language_view_model.dart';
import '../view_models/scanner_view_model.dart';

import '../view/screens/splash_screen.dart';
import '../view/screens/onboarding_screen.dart';
import '../view/screens/language_screen.dart';
 
import '../view/screens/scanner_screen.dart';
import '../view/screens/scanner_preview_screen.dart';
import '../view/screens/processing_screen.dart';
import '../view/screens/plant_identification_result_screen.dart';
import '../view_models/plant_result_view_model.dart';
import '../view_models/diagnosis_view_model.dart';
import '../view/screens/plant_diagnosis_result_screen.dart';
import '../view_models/water_calculation_view_model.dart';
import '../view/screens/water_questions_screen.dart';
import '../view/screens/water_result_screen.dart';

import '../view_models/history_view_model.dart';

import '../view_models/light_meter_view_model.dart';
import '../view/screens/light_meter_screen.dart';
import '../view/screens/light_meter_info_screen.dart';
import '../view_models/settings_view_model.dart';

import '../view/screens/premium_screen.dart';
import '../view_models/premium_view_model.dart';
import '../view/screens/privacy_policy_screen.dart';
import '../view/screens/main_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class PlantIdentifierApp extends StatefulWidget {
  const PlantIdentifierApp({super.key});

  @override
  State<PlantIdentifierApp> createState() => _PlantIdentifierAppState();
}

class _PlantIdentifierAppState extends State<PlantIdentifierApp> 
    with WidgetsBindingObserver {
  final NavigationService _navigationService = NavigationService();
  final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
      debugPrint('📱 APP LIFECYCLE: $state');

      if (state == AppLifecycleState.paused) {
    // App going to background
    debugPrint('📱 App going to background - cleaning up');
    
    // Force camera cleanup if scanner is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
      //  final navigatorKey = _navigationService.navigatorKey;
      final navigatorKey = NavigationService.navigatorKey;

        if (navigatorKey.currentContext != null) {
          final scannerViewModel = navigatorKey.currentContext!.read<ScannerViewModel>();
          scannerViewModel.disposeCamera();
        }
      } catch (e) {
        debugPrint('📱 Background cleanup skipped: $e');
      }
    });
  } else if (state == AppLifecycleState.resumed) {
    debugPrint('📱 App resumed from background');
  }
  }

  @override
  Widget build(BuildContext context) {
    final languageViewModel = Provider.of<LanguageViewModel>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(
          create: (context) => ScannerViewModel(ScannerService()),
        ),

        ChangeNotifierProvider(create: (_) => PlantResultViewModel()),
        ChangeNotifierProvider(create: (_) => DiagnosisViewModel()),
        ChangeNotifierProvider(create: (_) => WaterCalculationViewModel()),
        ChangeNotifierProvider(create: (_) => LightMeterViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),

        Provider<NavigationService>(create: (_) => _navigationService), // Use local variable
        Provider<CameraManager>(create: (_) => CameraManager()),
        ChangeNotifierProvider(create: (_) => PremiumViewModel()),
      ],
      child:  Consumer<LanguageViewModel>(
      builder: (context, languageViewModel, child) {
        return MaterialApp(


        title: 'Plant Identifier',


      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,

     //  Use the locale from LanguageViewModel
        locale: languageViewModel.currentLocale,

      localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
],
supportedLocales: const [
          Locale('en'), // English
          Locale('ur'), // Urdu
          Locale('de'), // German
          Locale('fr'), // French
          Locale('ar'), // Arabic
          Locale('es'), // Spanish
          Locale('ja'), // Japanese
          Locale('ko'), // Korean
        ],

        navigatorKey: NavigationService.navigatorKey,
        
        localeResolutionCallback: (locale, supportedLocales) {
          // If the device locale is supported, use it
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          // Otherwise, use the first supported locale (English)
          return supportedLocales.first;
        },


        theme: AppTheme.lightTheme,
      //  navigatorKey: _navigationService.navigatorKey, // Use local variable
      // final NavigationService _navigationService = NavigationService();
       
        navigatorObservers: [_routeObserver], // Use local variable
        initialRoute: AppRoutes.splash,
        debugShowCheckedModeBanner: false,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.language: (context) {
            final arguments =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            final showBackButton = arguments?['showBackButton'] ?? true;
            return LanguageScreen(showBackButton: showBackButton);
          },
          AppRoutes.home: (context) => const MainScreen(),
          AppRoutes.scanner: (context) => const ScannerScreen(),
          AppRoutes.scannerPreview: (context) => const ScannerPreviewScreen(),
          AppRoutes.processing: (context) => const ProcessingScreen(),
          AppRoutes.plantIdentificationResult: (context) =>
              const PlantIdentificationResultScreen(),
          AppRoutes.plantDiagnosisResult: (context) =>
              const PlantDiagnosisResultScreen(),
          AppRoutes.waterQuestions: (context) => const WaterQuestionsScreen(),
          AppRoutes.waterResult: (context) => const WaterResultScreen(),
          AppRoutes.lightMeter: (context) => const LightMeterScreen(),
          AppRoutes.lightMeterInfo: (context) => const LightMeterInfoScreen(),
          AppRoutes.premium: (context) => const PremiumScreen(),
          AppRoutes.privacyPolicy: (context) => const PrivacyPolicyScreen(),
        },
         onGenerateRoute: (settings) {
    debugPrint('🚨 CURRENT ROUTE: ${settings.name}');      
    debugPrint('🚨 ROUTE NOT FOUND: ${settings.name}');
    debugPrint('🚨 Arguments: ${settings.arguments}');
    return null;
  },
      );
      }
      )
    );
  }
}