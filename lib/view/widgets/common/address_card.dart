import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/responsive_helper.dart';
import '../../../utils/constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class AddressCard extends StatelessWidget {
  final String locationName;
  final String address;
  final VoidCallback onEditPressed;

  const AddressCard({
    super.key,
    required this.locationName,
    required this.address,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
     
      child: Container(
        width: ResponsiveHelper.responsiveWidth(343, context),
        height: ResponsiveHelper.responsiveHeight(60, context),
        margin: EdgeInsets.symmetric( 
          horizontal: ResponsiveHelper.responsiveWidth(16, context),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.addressBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Location Icon and Address Text
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: ResponsiveHelper.responsiveWidth(8, context),
                  right: ResponsiveHelper.responsiveWidth(8, context),
                  top: ResponsiveHelper.responsiveHeight(10, context),
                  bottom: ResponsiveHelper.responsiveHeight(10, context),
                ),
                child: Row(
                  children: [
                    // Location Icon
                    SvgPicture.asset(
                      AppConstants.locationIcon,
                      width: ResponsiveHelper.responsiveWidth(26, context),
                      height: ResponsiveHelper.responsiveWidth(26, context),
                    ),
                    SizedBox(width: ResponsiveHelper.responsiveWidth(12, context)),
                    
                    // Address Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            locationName,
                            style: AppTypography.addressTitle.copyWith(
                              fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveHelper.responsiveHeight(2, context)),
                          Text(
                            address,
                            style: AppTypography.addressSubtitle.copyWith(
                              fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Edit Icon
            Padding(
              padding: EdgeInsets.only(
                right: ResponsiveHelper.responsiveWidth(16, context),
              ),
              child: GestureDetector(
                onTap: onEditPressed,
                child: SvgPicture.asset(
                  AppConstants.editIcon,
                  width: ResponsiveHelper.responsiveWidth(20, context),
                  height: ResponsiveHelper.responsiveHeight(20, context),
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}