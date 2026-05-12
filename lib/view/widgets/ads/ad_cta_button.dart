import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ad_design_tokens.dart';

class AdCtaButton extends StatelessWidget {
  final String text;
  final double scale;
  final double width;
  final double height;
  final double radius;
  final double fontSize;

  const AdCtaButton({
    super.key,
    required this.text,
    required this.scale,
    required this.width,
    required this.height,
    this.radius = 8,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final actualHeight = math.max(height, 28).toDouble();
    final actualRadius = radius <= 0
        ? 0.0
        : AdDesignTokens.scaledSize(radius, scale, min: 6);

    return SizedBox(
      width: width,
      height: actualHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(actualRadius),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AdDesignTokens.ctaStart, AdDesignTokens.ctaEnd],
          ),
        ),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AdDesignTokens.ctaText,
              fontFamily: AdDesignTokens.fontFamily,
              fontSize: AdDesignTokens.scaledFont(fontSize, scale, min: 11),
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
