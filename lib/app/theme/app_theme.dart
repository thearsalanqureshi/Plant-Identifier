import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: AppColors.white,
    fontFamily: 'DMSans',
    textTheme: const TextTheme(
      headlineMedium: AppTypography.headlineMedium,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      background: AppColors.white,
    ),
  );
}