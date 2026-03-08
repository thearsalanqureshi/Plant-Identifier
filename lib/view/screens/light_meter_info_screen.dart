import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../utils/constants.dart';

class LightMeterInfoScreen extends StatefulWidget {
  const LightMeterInfoScreen({super.key});

 @override
  State<LightMeterInfoScreen> createState() => _LightMeterInfoScreen();
}

class _LightMeterInfoScreen extends State<LightMeterInfoScreen> {
 @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.responsiveWidth(16, context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button with proper spacing
         //     SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
         //     IconButton(
         //       icon: const Icon(Icons.arrow_back, color: AppColors.black),
         //       onPressed: () => Navigator.of(context).pop(),
         //       padding: EdgeInsets.zero,
         //       constraints: const BoxConstraints(),
         //     ),
             SizedBox(height: ResponsiveHelper.responsiveHeight(22, context)),

              // Title
              Center(
                child: Text(
                //  'How To Use Light Meter?',
                AppLocalizations.of(context).light_info_title,
                  style: AppTypography.onboardingTitle.copyWith(
                    fontSize: ResponsiveHelper.responsiveFontSize(20, context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: ResponsiveHelper.responsiveHeight(32, context)),

              // Instructions List with Images
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildInstructionWithImage(
                      context,
                      number: 1,
                    //  text: 'Keep your front camera facing the light source.',
                      text: AppLocalizations.of(context).light_info_step1,

                      imagePath: AppConstants.lightMeterStep1,
                    ),
                    SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),

                    _buildInstructionWithImage(
                      context,
                      number: 2,
                    //  text: 'Move phone around plant to measure light from all angles',
                     text: AppLocalizations.of(context).light_info_step2,

                      imagePath: AppConstants.lightMeterStep2,
                    ),
                    SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),

                    _buildInstructionWithImage(
                      context,
                      number: 3,
                    //  text: 'Check light levels at mid-day for the most accurate results',
                     text: AppLocalizations.of(context).light_info_step3,
                      imagePath: AppConstants.lightMeterStep3,
                    ),
                    SizedBox(height: ResponsiveHelper.responsiveHeight(32, context)),
                  ],
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.buttonHeight(context),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.responsiveWidth(100, context),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                  //  'Continue',
                  AppLocalizations.of(context).light_info_continue,
                    style: AppTypography.buttonText.copyWith(
                      fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.responsiveHeight(34, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionWithImage(
    BuildContext context, {
    required int number,
    required String text,
    required String imagePath,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number Circle
            Container(
              width: ResponsiveHelper.responsiveWidth(24, context),
              height: ResponsiveHelper.responsiveWidth(24, context),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.responsiveWidth(12, context)),

            // Instruction Text
            Expanded(
              child: Text(
                text,
                style:
                AppTypography.bodyMedium.copyWith(
                  fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),

        // Space between text and image
        SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),

        // Responsive Image Container
        _buildExampleImage(context, imagePath),
      ],
    );
  }

  Widget _buildExampleImage(BuildContext context, String imagePath) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive height based on screen width
        final imageHeight = constraints.maxWidth * 0.35; // 35% of screen width
        final minHeight = ResponsiveHelper.responsiveHeight(100, context);
        final maxHeight = ResponsiveHelper.responsiveHeight(200, context);

        return Container(
          width: double.infinity,
          height: imageHeight.clamp(minHeight, maxHeight), // Responsive height with limits
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.responsiveWidth(10, context),
            ),
            color: AppColors.lightGray,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.responsiveWidth(10, context),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.lightGray,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: ResponsiveHelper.responsiveWidth(32, context),
                        color: AppColors.mediumGray,
                      ),
                      SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
                      Text(
                      //  'Image not available',
                      AppLocalizations.of(context).light_info_image_error,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mediumGray,
                          fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}