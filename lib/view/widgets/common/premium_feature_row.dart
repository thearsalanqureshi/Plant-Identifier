import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';

class PremiumFeatureRow extends StatelessWidget {
  final String title;
  final bool isIncludedInPro;
  final bool isIncludedInBasic;

  const PremiumFeatureRow({
    Key? key,
    required this.title,
    required this.isIncludedInPro,
    required this.isIncludedInBasic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.responsiveHeight(12, context)),
      child: Row(
        children: [
          // Feature Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                color: const Color(0xFF1E1F24),
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.responsiveWidth(60, context)),
          
          // Pro Column
          Container(
            width: ResponsiveHelper.responsiveWidth(40, context),
            child: isIncludedInPro
                ? Image.asset(
                    'assets/icons/ic_tick_green.png', // Green tick icon
                    width: ResponsiveHelper.responsiveWidth(24, context),
                    height: ResponsiveHelper.responsiveHeight(24, context),
                  )
                : const SizedBox(),
          ),
          
          SizedBox(width: ResponsiveHelper.responsiveWidth(20, context)),
          
          // Basic Column  
          Container(
            width: ResponsiveHelper.responsiveWidth(40, context),
            child: isIncludedInBasic
                ? Image.asset(
                    'assets/icons/ic_tick_green.png', // Green tick icon
                    width: ResponsiveHelper.responsiveWidth(24, context),
                    height: ResponsiveHelper.responsiveHeight(24, context),
                  )
                : Image.asset(
                    'assets/icons/ic_lock.png', // Lock icon for restricted features
                    width: ResponsiveHelper.responsiveWidth(24, context),
                    height: ResponsiveHelper.responsiveHeight(24, context),
                  ),
          ),
        ],
      ),
    );
  }
}