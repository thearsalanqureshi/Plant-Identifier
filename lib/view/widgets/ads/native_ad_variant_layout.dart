import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ad_badge.dart';
import 'ad_design_tokens.dart';
import 'native_ad_data.dart';

typedef AdScaledCardBuilder =
    Widget Function(BuildContext context, double scale);

class AdScaledCard extends StatelessWidget {
  final double baseWidth;
  final double baseHeight;
  final Color backgroundColor;
  final double radius;
  final AdScaledCardBuilder builder;

  const AdScaledCard({
    super.key,
    required this.baseWidth,
    required this.baseHeight,
    required this.builder,
    this.backgroundColor = AdDesignTokens.backgroundBlue,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : baseWidth;
        final actualWidth = math.min(parentWidth, baseWidth);
        final scale = actualWidth / baseWidth;
        final scaledRadius = radius <= 0
            ? 0.0
            : AdDesignTokens.scaledSize(radius, scale, min: 8);

        return Center(
          child: SizedBox(
            width: actualWidth,
            height: baseHeight * scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(scaledRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(scaledRadius),
                child: builder(context, scale),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AdTextBlock extends StatelessWidget {
  final NativeAdData data;
  final double scale;
  final bool showBadge;
  final bool badgeBeforeTitle;
  final bool centered;
  final int titleMaxLines;
  final int bodyMaxLines;
  final double titleSize;
  final double bodySize;
  final Color titleColor;
  final Color bodyColor;

  const AdTextBlock({
    super.key,
    required this.data,
    required this.scale,
    this.showBadge = true,
    this.badgeBeforeTitle = false,
    this.centered = false,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    this.titleSize = 14,
    this.bodySize = 12,
    this.titleColor = AdDesignTokens.mainText,
    this.bodyColor = AdDesignTokens.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    if (centered) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            data.title,
            maxLines: titleMaxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: _titleStyle(),
          ),
          SizedBox(height: AdDesignTokens.scaledSize(6, scale, min: 4)),
          Text(
            data.body,
            maxLines: bodyMaxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: _bodyStyle(),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showBadge && badgeBeforeTitle) ...[
              AdBadge(scale: scale),
              SizedBox(width: AdDesignTokens.scaledSize(5, scale, min: 4)),
            ],
            Flexible(
              child: Text(
                data.title,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: _titleStyle(),
              ),
            ),
            if (showBadge && !badgeBeforeTitle) ...[
              SizedBox(width: AdDesignTokens.scaledSize(5, scale, min: 4)),
              AdBadge(scale: scale),
            ],
          ],
        ),
        SizedBox(height: AdDesignTokens.scaledSize(5, scale, min: 3)),
        Text(
          data.body,
          maxLines: bodyMaxLines,
          overflow: TextOverflow.ellipsis,
          style: _bodyStyle(),
        ),
      ],
    );
  }

  TextStyle _titleStyle() {
    return TextStyle(
      color: titleColor,
      fontFamily: AdDesignTokens.fontFamily,
      fontSize: AdDesignTokens.scaledFont(titleSize, scale, min: 11),
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: 0,
    );
  }

  TextStyle _bodyStyle() {
    return TextStyle(
      color: bodyColor,
      fontFamily: AdDesignTokens.fontFamily,
      fontSize: AdDesignTokens.scaledFont(bodySize, scale, min: 10),
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0,
    );
  }
}

class AdCtaPanel extends StatelessWidget {
  final String text;
  final double scale;
  final BorderRadius borderRadius;

  const AdCtaPanel({
    super.key,
    required this.text,
    required this.scale,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
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
            fontSize: AdDesignTokens.scaledFont(13, scale, min: 11),
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
