import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../view_models/home_view_model.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../data/services/analytics_service.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/feature_card.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../view/screens/light_meter_screen.dart';
import '../../../l10n/app_localizations.dart'; 
// import '../../../data/services/camera_pre_warm_service.dart';
// import '../widgets/common/address_card.dart';
// import '../../../view_models/light_meter_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');

    // Log screen view
  AnalyticsService.logScreenView(screenName: 'Home');
  debugPrint('📊 Analytics: Home screen viewed');
  }


  void _handleFeatureTap(String featureId, BuildContext context) {
    debugPrint('💣 HOME: Feature tapped - $featureId');

    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final validatedFeature = viewModel.validateFeatureAccess(featureId);
     debugPrint('💣 HOME: Validated feature - $validatedFeature');

    switch (validatedFeature) {
      case 'identify':
        debugPrint('💣💣💣 NAVIGATING TO SCANNER with mode: identify');
        Navigator.pushNamed(
          context,
          AppRoutes.scanner,
          arguments: {'mode': 'identify'},
        ); //'identify');
        break;
      case 'diagnose':
        Navigator.pushNamed(
          context,
          AppRoutes.scanner,
          arguments: {'mode': 'diagnose'},
        ); //'diagnose');
        break;
      case 'water':
        Navigator.pushNamed(
          context,
          AppRoutes.scanner,
          arguments: {'mode': 'water'},
        ); //'waterCalculator');
        break;
      case 'light':
        _preInitializeLightMeter(context);

        //   Navigator.pushNamed(context, AppRoutes.lightMeter);
        break;
      default:
        // Show error or fallback
         final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.home_feature_not_available(featureId)),
          ),
        );
    }
  }

  void _preInitializeLightMeter(BuildContext context) {
    // Simple navigation without complex pre-warming
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LightMeterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  debugPrint('💣 ${runtimeType} BUILD CALLED');

  debugPrint('💣 HOME SCREEN BUILD CALLED');
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(
                onPremiumPressed: () {
                  // First execute any business logic
                  final viewModel = Provider.of<HomeViewModel>(
                    context,
                    listen: false,
                  );
                  viewModel.handlePremiumAccess();

                  // Then navigate (this stays in the View)
                  Navigator.pushNamed(context, AppRoutes.premium);
                },
              ),
            

         /* Padding(
              padding: EdgeInsets.only(
                top: ResponsiveHelper.responsiveHeight(1, context),
              ),
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  return AddressCard(
                    locationName: viewModel.locationName,
                   address: viewModel.address,
                    onEditPressed: viewModel.editAddress,
                  );
                },
              ),
            ),
         */

            // Features Section
            Expanded(child: _buildFeaturesSection()),
          ],
        ),
      ),
    );
  }

  /// Builds the main features section with proper spacing
  Widget _buildFeaturesSection() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),

              // Large Features with 12px spacing
              ..._buildLargeFeatures(context, viewModel),

              // Small Features Section
              _buildSmallFeaturesSection(context, viewModel),

              SizedBox(height: ResponsiveHelper.responsiveHeight(20, context)),
             

  // Test Crash Button           
/* 
ElevatedButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash();
  },
  child: Text('Test Crash'),
)
*/

/*
ElevatedButton(
  onPressed: () async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('📱 FCM TOKEN: $token');
    await Clipboard.setData(ClipboardData(text: token ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token copied to clipboard')),
    );
  },
  child: Text('Get FCM Token'),
)
 */  
            ],
            
          ),
        );
      },
    );
  }
  

  /// Builds large feature cards (Identify, Diagnose)
  List<Widget> _buildLargeFeatures(
    BuildContext context,
    HomeViewModel viewModel,
  ) {

     final l10n = AppLocalizations.of(context);

    return viewModel.largeFeatures.map((feature) {

       // Map feature IDs to localized strings
    String title;
    String subtitle;

     switch (feature.id) {
      case 'identify':
        title = l10n.identify;
        subtitle = l10n.home_identify_subtitle;
        break;
      case 'diagnose':
        title = l10n.diagnose;
        subtitle = l10n.home_diagnose_subtitle;
        break;
      default:
        title = feature.title; // fallback
        subtitle = feature.subtitle; // fallback
    }

      return Column(
        children: [
          FeatureCard(
            title: title,
            subtitle: subtitle,
            size: feature.size,
            type: feature.type,
            onTap: () => _handleFeatureTap(feature.id, context),
          ),
        //  SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015), // 1.5% of screen
        ],
      );
    }).toList();
  }

  /// Builds small feature cards (Water Calculator, Light Meter)
  Widget _buildSmallFeaturesSection(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
     final l10n = AppLocalizations.of(context)!; // ← Get localized strings

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveWidth(16, context),
      ),
      child: Row(
        children: viewModel.smallFeatures.map((feature) {

           // Map feature IDs to localized strings
        String title;
        String subtitle;

         switch (feature.id) {
          case 'water':
            title = l10n.water_calculator;
            subtitle = l10n.home_water_subtitle;
            break;
          case 'light':
            title = l10n.light_meter_title;
            subtitle = l10n.home_light_subtitle;
            break;
          default:
            title = feature.title; // fallback
            subtitle = feature.subtitle; // fallback
        }

          return Expanded(
            child: Padding(
           //   padding: EdgeInsets.symmetric(
            //    horizontal: ResponsiveHelper.responsiveWidth(4, context),
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.01, // 1% gap
              ),
              child: FeatureCard(
                title: title,
                subtitle: subtitle,
                size: feature.size,
                type: feature.type,
                onTap: () => _handleFeatureTap(feature.id, context),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}