import 'dart:math' as math;

import 'package:flutter/material.dart';

class AdDesignTokens {
  const AdDesignTokens._();

  static const String fontFamily = 'DMSans';

  static const Color backgroundBlue = Color(0xFFDAE4F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color badge = Color(0xFFD39800);
  static const Color logoBackground = Color(0xFF070712);
  static const Color mainText = Color(0xFF333333);
  static const Color bodyText = Color(0xFF6A6A6A);
  static const Color ctaStart = Color(0xFF00ACC4);
  static const Color ctaEnd = Color(0xFF0BAC8B);
  static const Color ctaText = Color(0xFFFFFFFF);
  static const Color loaderStart = Color(0xFF005AC3);
  static const Color loaderEnd = Color(0xFF8667D1);
  static const Color shadow = Color(0x1F070712);

  static double scaledFont(double value, double scale, {double min = 10}) {
    return math.max(value * scale, min);
  }

  static double scaledSize(double value, double scale, {double min = 0}) {
    return math.max(value * scale, min);
  }
}
