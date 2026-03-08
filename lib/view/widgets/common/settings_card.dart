import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:plant_identifier_app/l10n/app_localizations.dart';
import '../../../utils/responsive_helper.dart';
import '../../../utils/constants.dart';
import '../../../app/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const SettingsCard({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(343, context),
      height: ResponsiveHelper.responsiveHeight(60, context),
      margin: EdgeInsets.only(bottom: ResponsiveHelper.smallSpacing(context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveWidth(10, context)),
        boxShadow: [ // ADD SHADOW FOR BETTER VISIBILITY
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveWidth(10, context)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.responsiveWidth(16, context),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: ResponsiveHelper.responsiveWidth(32, context),
                  height: ResponsiveHelper.responsiveHeight(32, context),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEDE0),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveWidth(8, context)),
                  ),
                  child: Center(
                    child: Image.asset(
                      iconPath,
                      width: ResponsiveHelper.responsiveWidth(20, context),
                      height: ResponsiveHelper.responsiveHeight(20, context),
                      errorBuilder: (context, error, stackTrace) { // ADD ERROR HANDLER
                        return Icon(Icons.error, size: ResponsiveHelper.responsiveWidth(20, context));
                      },
                    ),
                  ),
                ),
                
                SizedBox(width: ResponsiveHelper.responsiveWidth(12, context)),
                
                // Title - FIXED OVERFLOW
                Expanded( // ADD EXPANDED TO PREVENT OVERFLOW
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                      color: const Color(0xFF1E1F24),
                    ),
                    overflow: TextOverflow.ellipsis, // PREVENT OVERFLOW
                  ),
                ),
                
                SizedBox(width: ResponsiveHelper.responsiveWidth(8, context)),
                
                // Right Arrow
                Image.asset(
                  AppConstants.rightArrow,
                  width: ResponsiveHelper.responsiveWidth(24, context),
                  height: ResponsiveHelper.responsiveHeight(24, context),
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.arrow_forward_ios, 
                      size: ResponsiveHelper.responsiveWidth(20, context),
                      color: const Color(0xFF1E1F24),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}