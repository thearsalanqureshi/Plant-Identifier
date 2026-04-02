import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../utils/constants.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback onPremiumPressed;

  const HomeAppBar({
    super.key,
    required this.onPremiumPressed
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final appBarHeight = context.h(56); // 56 from design height
    final horizontalPadding = context.w(16);

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        height: appBarHeight,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isMobile ? context.h(8) : context.h(12),
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.lightGray,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // App Title
            Text(
              AppLocalizations.of(context).appBarTitle,
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontWeight: FontWeight.w900,
                fontSize: isTablet ? context.sp(28) : (isMobile ? context.sp(22) : context.sp(24)),
                height: 1.0,
                letterSpacing: 0,
                color: AppColors.black,
              ),
            ),
            const Spacer(),
            // Premium Button - Commented out for now
            // _buildPremiumButton(context),
          ],
        ),
      ),
    );
  }

// Commented out the premium button entirely
/*
  Widget _buildPremiumButton(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPremiumPressed,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? context.w(12) : context.w(16),
            vertical: isMobile ? context.h(6) : context.h(8),
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5A623), Color(0xFFF7B42C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF5A623).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: isMobile ? context.w(14) : context.w(16),
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                // Use premium_title or premium_upgrade from your localization
                // Comment out if no localization key exists
                // AppLocalizations.of(context).premium_title,
                'Premium', // Fallback text
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? context.sp(12) : context.sp(14),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  */
}

// Correct but commenting out for enhancement 01/04/26 05:53am
/*import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';

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
}*/