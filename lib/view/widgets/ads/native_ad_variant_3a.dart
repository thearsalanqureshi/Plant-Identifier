import 'package:flutter/material.dart';

import 'ad_cta_button.dart';
import 'ad_design_tokens.dart';
import 'native_ad_data.dart';
import 'native_ad_variant_layout.dart';

class NativeAdVariant3a extends StatelessWidget {
  final NativeAdData data;

  const NativeAdVariant3a({super.key, this.data = NativeAdData.dummyNoMedia});

  @override
  Widget build(BuildContext context) {
    return AdScaledCard(
      baseWidth: 364,
      baseHeight: 66,
      radius: 10,
      builder: (context, scale) {
        final padding = AdDesignTokens.scaledSize(10, scale, min: 8);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: AdDesignTokens.scaledSize(8, scale, min: 6),
          ),
          child: Row(
            children: [
              Expanded(
                child: AdTextBlock(
                  data: data,
                  scale: scale,
                  showBadge: true,
                  badgeBeforeTitle: false,
                  titleMaxLines: 1,
                  bodyMaxLines: 1,
                  titleSize: 13,
                  bodySize: 11,
                ),
              ),
              SizedBox(width: AdDesignTokens.scaledSize(10, scale, min: 8)),
              AdCtaButton(
                text: data.cta,
                scale: scale,
                width: AdDesignTokens.scaledSize(88, scale, min: 74),
                height: AdDesignTokens.scaledSize(36, scale, min: 30),
                radius: 18,
                fontSize: 12,
              ),
            ],
          ),
        );
      },
    );
  }
}
