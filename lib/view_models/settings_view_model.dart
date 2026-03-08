import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../data/services/analytics_service.dart';
import '/view/widgets/common/rating_bottom_sheet.dart';
import '/app/navigation/navigation_service.dart';
import '/app/navigation/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:store_redirect/store_redirect.dart';

class SettingsViewModel with ChangeNotifier {
  // Navigation methods
  void navigateToLanguage(BuildContext context) {
    final navigationService = context.read<NavigationService>();
   // navigationService.pushNamed(AppRoutes.language);

   navigationService.pushNamed(AppRoutes.language, arguments: {'showBackButton': true});
  }

  void navigateToPremium(BuildContext context) {
    final navigationService = context.read<NavigationService>();
    navigationService.pushNamed(AppRoutes.premium);
  }

 
 // void navigateToPrivacyPolicy(BuildContext context) {
    // Will implement later
 // }

  // Rating functionality
  void showRatingBottomSheet(BuildContext context) {
debugPrint('🟡 Rating bottom sheet opening'); 
     
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RatingBottomSheet(
         onRateNow: () {
           debugPrint('🟢 Rate Now tapped'); 

          _redirectToStore();
         },
      ),
    );
  }

  // Private method to handle store redirection
  void _redirectToStore() {
      debugPrint('🔄 Redirecting to store...');
    try {
     
      // For Android - opens Play Store
      // For iOS - opens App Store
      StoreRedirect.redirect(
        androidAppId:  "com.plantidentifier.nature.rose.identifier.plant", //"com.google.android.youtube",     // REPLACE with your package name
     
      //  iOSAppId: "1234567890",  // REPLACE with your iOS app ID if any
    
      );
       debugPrint('✅ StoreRedirect called');

    } catch (e) {
       debugPrint('❌ StoreRedirect error: $e');
      // Fallback: Open web Play Store URL
      _openStoreFallback();
    }
  }

  // Fallback method using url_launcher
  void _openStoreFallback() async {
    // Android Play Store URL
    const androidUrl = 'https://play.google.com/store/apps/details?id=com.plantidentifier.nature.rose.identifier.plant';
    // iOS App Store URL
   // const iosUrl = 'https://apps.apple.com/app/id1234567890';  // If iOS
    
    final uri = Uri.parse(androidUrl);  // Use android for now
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Share functionality
  void shareApp(BuildContext context) {
    // Implement share functionality
    // You can use share_plus package
  }

void sendFeedback(BuildContext context)  {
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

  /*
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: Show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open email app. Please email us at $email'),
        ),
      );
    }
  } catch (e) {
    debugPrint('Error launching email: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to open email. Please try again later.'),
      ),
    );
  }
  */


    // Add this method to SettingsViewModel
    
void navigateToPrivacyPolicy(BuildContext context) {
  final navigationService = context.read<NavigationService>();
  navigationService.pushNamed(AppRoutes.privacyPolicy);
}
  }
  

/*
  void navigateToPrivacyPolicy(BuildContext context) async {
  final url = 'https://docs.google.com/document/d/e/2PACX-1vQyde-pEspsxh1UxOYshNh2yLRy8HWTlB4FzabeRdXXghCB8iHAE7kw7KFMMZZUzDRYwnDtdqOg17Sd/pub';

  final uri = Uri.parse(url);

    debugPrint('🔗 Opening privacy policy: $url');
  
  try {
    if (await canLaunchUrl(uri)) {
      debugPrint('✅ Can launch URL');
      await launchUrl(uri);
    } else {

        debugPrint('❌ Cannot launch URL');

      // Fallback: Show snackbar with the URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open browser. Please visit: $url'),
        ),
      );
    }
  } catch (e) {
    debugPrint('Error launching privacy policy: $e');
  }
}
*/
  