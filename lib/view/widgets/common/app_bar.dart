import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
// import '../../../app/theme/app_typography.dart';
//import '../../../utils/constants.dart';
// import 'pro_button.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback onPremiumPressed;
  
  const HomeAppBar({
    super.key, 
    required this.onPremiumPressed
  });

  @override
   Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 375px width
      height: ResponsiveHelper.responsiveHeight(51, context), // 51px height
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveWidth(16, context), // left/right 16px
        vertical: ResponsiveHelper.responsiveHeight(12.5, context), // top/bottom 12.5px
      ),
      child: Row(
        children: [
          // App Title
          Text(
           // AppStrings.appBarTitle,
            AppLocalizations.of(context).appBarTitle,
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontWeight: FontWeight.w900, 
              fontSize: ResponsiveHelper.responsiveFontSize(22, context),
              height: 1.0, // 100% line height
              letterSpacing: 0,
              color: AppColors.black,
            ),
          ),
          
          const Spacer(),
          
       //   ProButton(onPressed: onPremiumPressed),
        ],
      ),
    );
  }
}