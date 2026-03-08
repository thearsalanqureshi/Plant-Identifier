import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants.dart';
import '../../../utils/responsive_helper.dart';
import '../../../view_models/settings_view_model.dart';
import '../../../app/theme/app_colors.dart';

class PremiumBanner extends StatelessWidget {
  const PremiumBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(343, context),
      height: ResponsiveHelper.responsiveHeight(120, context),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF6E5),
        borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveWidth(12, context)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left decorative image - CORRECTED POSITION
          Positioned(
            left: ResponsiveHelper.responsiveWidth(-70, context), // MOVED CLOSER
            top: ResponsiveHelper.responsiveHeight(-4, context), // MOVED CLOSER
            child: Image.asset(
              AppConstants.premiumLeft,
              width: ResponsiveHelper.responsiveWidth(150, context), // SMALLER
              height: ResponsiveHelper.responsiveHeight(122, context),
              errorBuilder: (context, error, stackTrace) {
                return Container();
              },
            ),
          ),
          
          // Right decorative image - CORRECTED POSITION
          Positioned(
            right: ResponsiveHelper.responsiveWidth(2, context), // MOVED CLOSER
            top: ResponsiveHelper.responsiveHeight(-2, context), // MOVED CLOSER
            child: Image.asset(
              AppConstants.premiumRight,
              width: ResponsiveHelper.responsiveWidth(160, context), // SMALLER
              height: ResponsiveHelper.responsiveHeight(122, context),
              errorBuilder: (context, error, stackTrace) {
                return Container();
              },
            ),
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                //  'Explore Premium Features\nFor Free',
                 AppLocalizations.of(context).widget_premium_banner_text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.responsiveFontSize(18, context),
                    color: const Color(0xFF1E1F24),
                    height: 1.2, // ADDED FOR BETTER LINE SPACING
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
                
                ElevatedButton(
                  onPressed: () {
                    context.read<SettingsViewModel>().navigateToPremium(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: const Color(0xFF1E3624),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveWidth(20, context)),
                      side: const BorderSide(color: AppColors.primaryGreen, width: 1),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.responsiveWidth(41, context),
                      vertical: ResponsiveHelper.responsiveHeight(13, context),
                    ),
                  ),
                  child: Text(
                  //  'Upgrade To Pro',
                   AppLocalizations.of(context).widget_premium_banner_button,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}