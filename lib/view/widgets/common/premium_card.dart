import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '/utils/responsive_helper.dart';

class PremiumCard extends StatelessWidget {
  final VoidCallback onUpgrade;

  const PremiumCard({
    super.key,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(343, context),
      height: ResponsiveHelper.responsiveHeight(120, context),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF6E5),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.responsiveWidth(12, context),
        ),
      ),
      child: Stack(
        children: [
          // Background Images
          Positioned(
            left: ResponsiveHelper.responsiveWidth(-83, context),
            top: ResponsiveHelper.responsiveHeight(-80, context),
            child: Image.asset(
              'assets/images/premium_left.png', // Add to assets
              width: ResponsiveHelper.responsiveWidth(200, context),
              height: ResponsiveHelper.responsiveHeight(200, context),
            ),
          ),
          Positioned(
            right: ResponsiveHelper.responsiveWidth(-23, context),
            top: ResponsiveHelper.responsiveHeight(-80, context),
            child: Image.asset(
              'assets/images/premium_right.png', // Add to assets
              width: ResponsiveHelper.responsiveWidth(200, context),
              height: ResponsiveHelper.responsiveHeight(200, context),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                //  'Explore Premium Features\nFor Free',
                 AppLocalizations.of(context).widget_premium_card_text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF1E1F24),
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
                
                // Upgrade Button
                Container(
                  width: ResponsiveHelper.responsiveWidth(200, context),
                  height: ResponsiveHelper.responsiveHeight(40, context),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF589C68),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onUpgrade,
                      child: Center(
                        child: Text(
                        //  'Upgrade To Pro',
                          AppLocalizations.of(context).widget_premium_card_button,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF1E3624),
                          ),
                        ),
                      ),
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