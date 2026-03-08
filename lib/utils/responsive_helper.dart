// lib/utils/responsive_helper.dart
import 'package:flutter/material.dart';

/// PRODUCTION-GRADE RESPONSIVE HELPER
/// 
/// CRITICAL FIXES:
/// 1. KEEPS ALL EXISTING METHOD NAMES - NO BREAKING CHANGES
/// 2. Fixes calculation logic to use MediaQuery.sizeOf (efficient)
/// 3. Adds system inset handling for Android 15 gesture navigation
/// 4. NO REWRITES NEEDED - All screens continue working
class ResponsiveHelper {
  const ResponsiveHelper._();
  
  // Reference design size (keep as reference only)
  static const double _designWidth = 375;
  static const double _designHeight = 812;
  
  /// ✅ FIXED: CORRECT pixel-perfect scaling based on design
  /// All existing screens use this - DO NOT CHANGE METHOD SIGNATURE
  static double responsiveWidth(double size, BuildContext context) {
    return (size / _designWidth) * MediaQuery.sizeOf(context).width;
  }
  
  /// ✅ FIXED: CORRECT pixel-perfect scaling based on design
  static double responsiveHeight(double size, BuildContext context) {
    return (size / _designHeight) * MediaQuery.sizeOf(context).height;
  }
  
  /// ✅ FIXED: Responsive font size with MIN/MAX caps
  /// Prevents text overflow on tablets
  static double responsiveFontSize(double size, BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / _designWidth;
    // CRITICAL: Cap scaling to prevent 100px text on tablets
    final cappedScale = scale.clamp(0.8, 1.2);
    return size * cappedScale;
  }
  
  /// ✅ NEW: Standard spacing utilities (optional, not breaking)
  static double standardSpacing(BuildContext context) => responsiveHeight(16, context);
  static double smallSpacing(BuildContext context) => responsiveHeight(8, context);
  static double largeSpacing(BuildContext context) => responsiveHeight(24, context);
  static double buttonHeight(BuildContext context) => responsiveHeight(56, context);
  static double iconSize(BuildContext context) => responsiveWidth(24, context);
  
  /// ✅ CRITICAL FIX: Bottom navigation bar height with system inset
  /// Use this ONLY in main_screen.dart
  static double bottomNavBarHeight(BuildContext context) {
    return 64 + MediaQuery.paddingOf(context).bottom;
  }
  
  /// ✅ CRITICAL FIX: Safe bottom position for gesture navigation
  /// Use this ONLY in screens with Positioned widgets
  static double safeBottomPosition(double fromBottom, BuildContext context) {
    return fromBottom + MediaQuery.paddingOf(context).bottom;
  }
}

/// ✅ EXTENSION - Keep exactly as is, add new getters
/// NO BREAKING CHANGES - All existing .w(20) calls continue working
extension ResponsiveExtension on BuildContext {
  // EXISTING - DO NOT CHANGE
  double w(double size) => ResponsiveHelper.responsiveWidth(size, this);
  double h(double size) => ResponsiveHelper.responsiveHeight(size, this);
  double sp(double size) => ResponsiveHelper.responsiveFontSize(size, this);
  
  // ✅ NEW: Safe area getters for Android 15 gesture navigation
  double get bottomInset => MediaQuery.paddingOf(this).bottom;
  double get topInset => MediaQuery.paddingOf(this).top;
  
  // ✅ NEW: Screen breakpoint detection
  bool get isMobile => MediaQuery.sizeOf(this).width < 600;
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600;
}