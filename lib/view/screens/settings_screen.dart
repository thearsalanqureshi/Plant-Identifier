import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plant_identifier_app/l10n/app_localizations.dart';
import '../../data/services/analytics_service.dart';
import '../../utils/constants.dart';
import '../../view_models/settings_view_model.dart';
import '../widgets/common/settings_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');

    // Log screen view
    AnalyticsService.logScreenView(screenName: 'Settings');
    debugPrint('📊 Analytics: Settings screen viewed');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    final settingsViewModel = context.watch<SettingsViewModel>();
    final localizations = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: Text(
          localizations.settings_title,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1E1F24),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),

              // Settings Cards
              SettingsCard(
                title: localizations.settings_app_language,
                iconPath: AppConstants.languageIcon,
                onTap: () => settingsViewModel.navigateToLanguage(context),
              ),

              SettingsCard(
                title: localizations.settings_rate_us,
                iconPath: AppConstants.rateIcon,
                onTap: () => settingsViewModel.showRatingBottomSheet(context),
              ),

              SettingsCard(
                title: localizations.settings_share_app,
                iconPath: "assets/icons/ic_share.png",
                onTap: () => settingsViewModel.shareApp(context),
              ),

              SettingsCard(
                title: localizations.settings_feedback,
                iconPath: AppConstants.rateIcon,
                onTap: _sendFeedback,
              ),

              SettingsCard(
                title: localizations.settings_privacy_policy,
                iconPath: AppConstants.privacyIcon,
                onTap: () {
                  debugPrint('🟡 Privacy Policy card tapped');
                  final viewModel = context.read<SettingsViewModel>();
                  debugPrint('🟢 ViewModel runtime type: ${viewModel.runtimeType}');
                  viewModel.navigateToPrivacyPolicy(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendFeedback() {
    final email = 'storenorthapps@gmail.com';
    final subject = 'Plant Identifier App Feedback';
    final body = 'Dear Plant Identifier Team,\n\n';

    final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');

    launchUrl(uri).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open email. Please email us at $email'),
        ),
      );
    });
  }
}



/* ------ Correct but unresponsive -------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plant_identifier_app/l10n/app_localizations.dart';
import '../../data/services/analytics_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_helper.dart';
import '../../view_models/settings_view_model.dart';
// import '../widgets/common/premium_banner.dart';
import '../widgets/common/settings_card.dart';
// import '../../app/navigation/navigation_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');


  // Log screen view
  AnalyticsService.logScreenView(screenName: 'Settings');
  debugPrint('📊 Analytics: Settings screen viewed');
  }
  

  @override
   Widget build(BuildContext context) {
   debugPrint('💣 ${runtimeType} BUILD CALLED');

    final settingsViewModel = context.watch<SettingsViewModel>();
   
     // Get localizations here - this will auto-update when language changes
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: Text(
          localizations.settings_title,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: ResponsiveHelper.responsiveFontSize(20, context),
            color: const Color(0xFF1E1F24),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
          child: Column(
            children: [
                // Premium Banner
          //    const PremiumBanner(),
              
              SizedBox(height: ResponsiveHelper.standardSpacing(context)),
              
              // Settings Cards
              SettingsCard(
                title: localizations.settings_app_language,
                iconPath: AppConstants.languageIcon, 
                onTap: () => settingsViewModel.navigateToLanguage(context),
              ),
              
              SettingsCard(
                title: localizations.settings_rate_us,
                iconPath: AppConstants.rateIcon, 
                onTap: () => settingsViewModel.showRatingBottomSheet(context),
              ),
              
              SettingsCard(
                title: localizations.settings_share_app,
                iconPath: "assets/icons/ic_share.png",
                onTap: () => settingsViewModel.shareApp(context),
              ),


            SettingsCard(
  title: localizations.settings_feedback,
  iconPath: AppConstants.rateIcon,
  onTap: _sendFeedback,
),
              
              
              SettingsCard(
                title: localizations.settings_privacy_policy,
                iconPath: AppConstants.privacyIcon,
                onTap: () { 
                   debugPrint('🟡 Privacy Policy card tapped'); 
                     final viewModel = context.read<SettingsViewModel>();
                   debugPrint('🟢 ViewModel runtime type: ${viewModel.runtimeType}');
                
                 viewModel.navigateToPrivacyPolicy(context);
            //  context.read<SettingsViewModel>().navigateToPrivacyPolicy(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendFeedback() {
  final email = 'storenorthapps@gmail.com';
  final subject = 'Plant Identifier App Feedback';
  final body = 'Dear Plant Identifier Team,\n\n';
  
  final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
  
  launchUrl(uri).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // ⚠️ FLAG: No matching localization key for this string
        content: Text('Could not open email. Please email us at $email'),
      ),
    );
  });
}
}*/