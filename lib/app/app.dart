import 'dart:async';
import 'package:flutter/material.dart';

import 'package:plant_identifier_app/data/services/scanner_service.dart';
import 'package:provider/provider.dart';
import '../view/widgets/ads/ad_design_preview_screen.dart';
import '../view/widgets/ads/app_open_ad_lifecycle_handler.dart';
import '../view/widgets/ads/ad_loader_overlay.dart';
import '../l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'navigation/app_routes.dart';
import '../data/services/camera_manager.dart';
import 'navigation/navigation_service.dart';

import '../view_models/splash_view_model.dart';
import '../view_models/onboarding_view_model.dart';
import '../view_models/ad_config_view_model.dart';
import '../view_models/ad_view_model.dart';
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
  final RouteObserver<PageRoute> _routeObserver =
      NavigationService.routeObserver;

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

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.resumed) {
      unawaited(CameraManager().handleAppLifecycleState(state));
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageViewModel>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(
          create: (_) {
            final viewModel = AdConfigViewModel();
            unawaited(viewModel.initialize());
            return viewModel;
          },
        ),
        ChangeNotifierProvider(create: (_) => AdViewModel()),
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

        Provider<NavigationService>(
          create: (_) => _navigationService,
        ), // Use local variable
        Provider<CameraManager>(create: (_) => CameraManager()),
        ChangeNotifierProvider(create: (_) => PremiumViewModel()),
      ],
      child: Consumer<LanguageViewModel>(
        builder: (context, languageViewModel, child) {
          return MaterialApp(
            title: 'Plant Identifier',

            // localizationsDelegates: AppLocalizations.localizationsDelegates,
            // supportedLocales: AppLocalizations.supportedLocales,

            //  Use the locale from LanguageViewModel
            locale: languageViewModel.currentLocale,

            builder: (context, child) {
              final appChild = MediaQuery.withClampedTextScaling(
                minScaleFactor: 1.0,
                maxScaleFactor: 1.2,
                child: child ?? const SizedBox.shrink(),
              );
              final appOpenLifecycleChild = AppOpenAdLifecycleHandler(
                child: appChild,
              );

              return Stack(
                children: [
                  appOpenLifecycleChild,
                  const Positioned.fill(child: AdLoaderOverlay()),
                ],
              );
            },

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
              // TODO(ads-preview): Remove this temporary route after ad UI QA.
              '/ad-design-preview': (context) => const AdDesignPreviewScreen(),
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.onboarding: (context) => const OnboardingScreen(),
              AppRoutes.language: (context) {
                final arguments =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final showBackButton = arguments?['showBackButton'] ?? true;
                final nextRouteAfterSave =
                    arguments?['nextRouteAfterSave'] as String?;
                return LanguageScreen(
                  showBackButton: showBackButton,
                  nextRouteAfterSave: nextRouteAfterSave,
                );
              },
              AppRoutes.home: (context) => const MainScreen(),
              AppRoutes.scanner: (context) => const ScannerScreen(),
              AppRoutes.scannerPreview: (context) =>
                  const ScannerPreviewScreen(),
              AppRoutes.processing: (context) => const ProcessingScreen(),
              AppRoutes.plantIdentificationResult: (context) =>
                  const PlantIdentificationResultScreen(),
              AppRoutes.plantDiagnosisResult: (context) =>
                  const PlantDiagnosisResultScreen(),
              AppRoutes.waterQuestions: (context) =>
                  const WaterQuestionsScreen(),
              AppRoutes.waterResult: (context) => const WaterResultScreen(),
              AppRoutes.lightMeter: (context) => const LightMeterScreen(),
              AppRoutes.lightMeterInfo: (context) =>
                  const LightMeterInfoScreen(),
              AppRoutes.premium: (context) {
                final arguments =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                return PremiumScreen(
                  nextRouteAfterPremium:
                      arguments?['nextRouteAfterPremium'] as String?,
                  nextRouteArguments: arguments?['nextRouteArguments'],
                  showRewardedInterstitialOnClose:
                      arguments?['showRewardedInterstitialOnClose'] == true,
                );
              },
              AppRoutes.privacyPolicy: (context) => const PrivacyPolicyScreen(),
            },
            onGenerateRoute: (settings) {
              debugPrint('🚨 CURRENT ROUTE: ${settings.name}');
              debugPrint('🚨 ROUTE NOT FOUND: ${settings.name}');
              debugPrint('🚨 Arguments: ${settings.arguments}');
              return null;
            },
          );
        },
      ),
    );
  }
}
