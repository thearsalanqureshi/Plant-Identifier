import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../view_models/premium_view_model.dart';
import '../widgets/common/premium_feature_row.dart';
import '../../app/theme/app_colors.dart';
import '../../app/navigation/navigation_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    final premiumViewModel = context.watch<PremiumViewModel>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Image.asset(
                    AppConstants.closeIcon,
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    final navigationService = context.read<NavigationService>();
                    navigationService.pop();
                  },
                ),
              ),

              SizedBox(height: screenHeight * 0.05), // 5% spacing

              // Crown Image
              Image.asset(
                AppConstants.premiumCrown,
                width: screenWidth * 0.2, // 20% of screen width
                height: screenWidth * 0.2,
              ),

              SizedBox(height: screenHeight * 0.03), // 3% spacing

              // Title
              Text(
                AppLocalizations.of(context).premium_upgrade,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: screenWidth * 0.06, // 6% of screen width
                  color: const Color(0xFF1E1F24),
                ),
              ),

              SizedBox(height: screenHeight * 0.02), // 2% spacing

              // Subtitle
              Text(
                AppLocalizations.of(context).premium_experience,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.035, // 3.5% of screen width
                  color: const Color(0xFF80828D),
                ),
              ),

              SizedBox(height: screenHeight * 0.04), // 4% spacing

              // Divider
              Image.asset(
                AppConstants.dividerLine,
                width: screenWidth * 0.7, // 70% of screen width
                height: 1,
              ),

              SizedBox(height: screenHeight * 0.03), // 3% spacing

              // Features Table Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    // Features Title
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).premium_features,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1E1F24),
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.15), // 15% spacing

                    // PRO Column Header
                    Container(
                      width: screenWidth * 0.1, // 10% of screen width
                      child: Text(
                        AppLocalizations.of(context).premium_pro,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1E1F24),
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.05), // 5% spacing

                    // Basic Column Header
                    Container(
                      width: screenWidth * 0.1, // 10% of screen width
                      child: Text(
                        AppLocalizations.of(context).premium_basic,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1E1F24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02), // 2% spacing

              // Features List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  itemCount: premiumViewModel.features.length,
                  itemBuilder: (context, index) {
                    final feature = premiumViewModel.features[index];
                    return PremiumFeatureRow(
                      title: feature.title,
                      isIncludedInPro: feature.isIncludedInPro,
                      isIncludedInBasic: feature.isIncludedInBasic,
                    );
                  },
                ),
              ),

              SizedBox(height: screenHeight * 0.02), // 2% spacing

              // Price Text
              Text(
                AppLocalizations.of(context).premium_price,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.035, // 3.5% of screen width
                  color: const Color(0xFF80828D),
                ),
              ),

              SizedBox(height: screenHeight * 0.02), // 2% spacing

              // Start Now Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: premiumViewModel.isLoading
                      ? null
                      : () => premiumViewModel.purchaseSubscription(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: premiumViewModel.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).premium_start_now,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02), // 2% spacing

              // Footer Text
              Text(
                AppLocalizations.of(context).premium_footer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.03, // 3% of screen width
                  color: const Color(0xFF80828D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*  ----- Correct but unresponsive -----
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/constants.dart';
import '../../view_models/premium_view_model.dart';
import '../widgets/common/premium_feature_row.dart';
import '../../app/theme/app_colors.dart';
import '../../app/navigation/navigation_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
  }

  @override
  Widget build(BuildContext context) {
   debugPrint('💣 ${runtimeType} BUILD CALLED');

    final premiumViewModel = context.watch<PremiumViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Image.asset(
                    AppConstants.closeIcon,
                    width: ResponsiveHelper.responsiveWidth(24, context),
                    height: ResponsiveHelper.responsiveHeight(24, context),
                  ),
                  onPressed: () {
                    final navigationService = context.read<NavigationService>();
                    navigationService.pop();
                  },
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(40, context)),
              
            
              Image.asset(
                AppConstants.premiumCrown,
                width: ResponsiveHelper.responsiveWidth(88, context),
                height: ResponsiveHelper.responsiveHeight(88, context),
              ),
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),
              
         
              Text(
              //  'Upgrade To Premium',
              AppLocalizations.of(context).premium_upgrade,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.responsiveFontSize(24, context),
                  color: const Color(0xFF1E1F24),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),
              
              // Subtitle
              Text(
              //  'Experience It All — Effortless and Uninterrupted',
               AppLocalizations.of(context).premium_experience,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                  color: const Color(0xFF80828D),
                ),
              ),
              
            
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(32, context)),
              
              // Divider
              Image.asset(
                 AppConstants.dividerLine, 
                width: ResponsiveHelper.responsiveWidth(291, context),
                height: ResponsiveHelper.responsiveHeight(1, context),
              ),
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),
              
              // Features Table Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.responsiveWidth(16, context),
                ),
                child: Row(
                  children: [
                    // Features Title 
                    Expanded(
                      child: Text(
                      //  'Features',
                      AppLocalizations.of(context).premium_features,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                          color: const Color(0xFF1E1F24),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: ResponsiveHelper.responsiveWidth(60, context)),
                    
                    // PRO Column Header
                    Container(
                      width: ResponsiveHelper.responsiveWidth(40, context),
                      child: Text(
                      //  'PRO',
                      AppLocalizations.of(context).premium_pro,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                          color: const Color(0xFF1E1F24),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: ResponsiveHelper.responsiveWidth(20, context)),
                    
                    // Basic Column Header
                    Container(
                      width: ResponsiveHelper.responsiveWidth(40, context),
                      child: Text(
                      //  'Basic',
                      AppLocalizations.of(context).premium_basic,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                          color: const Color(0xFF1E1F24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
              
              // Features List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.responsiveWidth(16, context),
                  ),
                  itemCount: premiumViewModel.features.length,
                  itemBuilder: (context, index) {
                    final feature = premiumViewModel.features[index];
                    return PremiumFeatureRow(
                      title: feature.title,
                      isIncludedInPro: feature.isIncludedInPro,
                      isIncludedInBasic: feature.isIncludedInBasic,
                    );
                  },
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),
              
              // Price Text
              Text(
              //  'Rs 750.00/Week After Free 3-Day Trial',
              AppLocalizations.of(context).premium_price,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                  color: const Color(0xFF80828D),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
              
              // Start Now Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.responsiveHeight(60, context),
                child: ElevatedButton(
                  onPressed: premiumViewModel.isLoading 
                      ? null 
                      : () => premiumViewModel.purchaseSubscription(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.responsiveWidth(100, context),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: premiumViewModel.isLoading
                      ? SizedBox(
                          width: ResponsiveHelper.responsiveWidth(20, context),
                          height: ResponsiveHelper.responsiveHeight(20, context),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                        //  'Start Now',
                        AppLocalizations.of(context).premium_start_now,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w700,
                            fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
              
              // Footer Text
              Text(
              //  'Subscription will auto-renew. Cancel anytime.',
               AppLocalizations.of(context).premium_footer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                  color: const Color(0xFF80828D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/