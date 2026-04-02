import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../utils/constants.dart';

class LanguageAppBar extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback onSavePressed;
  final bool canSave;

  const LanguageAppBar({
    super.key,
    required this.onBackPressed,
    required this.onSavePressed,
    this.canSave = true,
  });

  @override
  Widget build(BuildContext context) {
     print(' LanguageAppBar - onBackPressed: $onBackPressed');
    return Container(
      width: double.infinity,
      height: ResponsiveHelper.responsiveHeight(48, context),
      margin: EdgeInsets.only(top: ResponsiveHelper.responsiveHeight(12, context)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back Button - ONLY SHOW IF onBackPressed IS NOT NULL
          if (onBackPressed != null) //                               THIS IS THE KEY FIX
          Positioned(
            left: ResponsiveHelper.responsiveWidth(16, context),
            child: _IconButton(
              icon: AppConstants.backIcon,
              onPressed: onBackPressed,
              iconColor: AppColors.backIconColor, 
            ),
          ),
          
          // Title
          Text(
          //  AppStrings.selectLanguage,
           AppLocalizations.of(context).selectLanguage,
            style: AppTypography.languageAppBar.copyWith(
              fontSize: ResponsiveHelper.responsiveFontSize(20, context),
            ),
          ),
          
          // Save Button
          Positioned(
            right: ResponsiveHelper.responsiveWidth(16, context),
            child: _IconButton(
              icon: AppConstants.tickIcon,
              onPressed: canSave ? onSavePressed : null,
              iconColor: canSave ? AppColors.tickIconColor : AppColors.tickIconColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;
  final Color iconColor;

  const _IconButton({
    required this.icon,
    this.onPressed,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: ResponsiveHelper.responsiveWidth(24, context),
        height: ResponsiveHelper.responsiveHeight(24, context),
        child: SvgPicture.asset(
          icon,
          color: iconColor,
          width: ResponsiveHelper.responsiveWidth(16, context),
          height: ResponsiveHelper.responsiveHeight(16, context),
        ),
      ),
    );
  }
}