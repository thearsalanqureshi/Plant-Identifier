import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Headline Medium - Used for "Plant Identifier" text
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 24,
    height: 1.0, // 100% line height
    letterSpacing: 0,
    color: AppColors.black,
  );

  // Body Large - For important body text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.black,
  );

  // Body Medium - For regular body text
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.darkGray,
  );

   // ONBOARDING STYLES

   // Headline - Used for onboarding titles
  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w900, // Black
    fontSize: 22,
    height: 1.0, // 100% line height
    letterSpacing: 0,
    color: AppColors.black,
  );

  // Body - Used for onboarding descriptions
  static const TextStyle onboardingBody = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 16,
    height: 1.0, // 100% line height
    letterSpacing: 0,
    color: AppColors.mediumGray,
  );

  // Button Text - Used for onboarding buttons
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 18,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.white,
  );

// HOME SCREEN STYLES

  // App Bar Title - Gabarito Black
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'Gabarito',
    fontWeight: FontWeight.w900, // Black
    fontSize: 22,
    height: 1.0, // 100% line height
    letterSpacing: 0,
    color: AppColors.black,
  );

  // Pro Button Text - Satoshi Bold
  static const TextStyle proButton = TextStyle(
    fontFamily: 'Satoshi',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 12,
    height: 1.33, // 16px line height
    letterSpacing: 0,
    color: AppColors.black,
  );

  // Address Title - Gabarito Medium
  static const TextStyle addressTitle = TextStyle(
    fontFamily: 'Gabarito',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 1.0, // 100% line height
    letterSpacing: 0,
    color: AppColors.black,
  );

  // Address Subtitle - Gabarito Medium (smaller)
  static const TextStyle addressSubtitle = TextStyle(
    fontFamily: 'Gabarito',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 12,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.black,
  );

  // Feature Card Title - DM Sans Bold
  static const TextStyle featureCardTitle = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 18,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.whiteText,
  );

  // Feature Card Subtitle - DM Sans Medium
  static const TextStyle featureCardSubtitle = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.whiteText87, // 87% opacity
  );

  // Small Card Title - DM Sans Bold
  static const TextStyle smallCardTitle = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 18,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.whiteText,
  );

  // Small Card Subtitle - DM Sans Medium
  static const TextStyle smallCardSubtitle = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.whiteText,
  );

  // Language Screen
  static const TextStyle languageAppBar = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 20,
    height: 1.0, // 100% line height
    letterSpacing: 0,
    color: AppColors.languageAppBarText,
  );

  static const TextStyle languageItem = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 16,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.languageAppBarText,
  );

  // Bottom NavBar
static const TextStyle bottomNavLabel = TextStyle(
  fontFamily: 'DMSans',
  fontWeight: FontWeight.w500, // Medium
  fontSize: 12,
  height: 1.0,
  letterSpacing: 0,
);
}