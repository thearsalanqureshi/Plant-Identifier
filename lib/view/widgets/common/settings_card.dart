import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/constants.dart';
import '../../../app/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const SettingsCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final horizontalPadding = isTablet ? 20.0 : 16.0;
    final verticalPadding = isTablet ? 14.0 : 12.0;
    final iconContainerSize = isTablet ? 44.0 : 38.0;
    final iconSize = isTablet ? 22.0 : 20.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Row(
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEDE0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      iconPath,
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Icon(Icons.error_outline, size: iconSize);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 22 : 16,
                      color: const Color(0xFF1E1F24),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: isTablet ? 28 : 24,
                  height: isTablet ? 28 : 24,
                  child: SvgPicture.asset(
                    AppConstants.rightArrow,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(Color(0xFF1E1F24), BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// Before Refactoring 12/03/26 - 02:45pm
/*import 'package:flutter/material.dart';

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
}*/