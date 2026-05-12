import 'package:flutter/material.dart';

import 'ad_design_tokens.dart';

class AdBadge extends StatelessWidget {
  final double scale;
  final String label;

  const AdBadge({super.key, required this.scale, this.label = 'AD'});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AdDesignTokens.scaledSize(5, scale, min: 4);
    final verticalPadding = AdDesignTokens.scaledSize(2, scale, min: 2);
    final radius = AdDesignTokens.scaledSize(3, scale, min: 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdDesignTokens.badge,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AdDesignTokens.white,
            fontFamily: AdDesignTokens.fontFamily,
            fontSize: AdDesignTokens.scaledFont(8, scale, min: 7),
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
