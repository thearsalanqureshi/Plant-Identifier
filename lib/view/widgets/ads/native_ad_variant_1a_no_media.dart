import 'package:flutter/material.dart';

import 'ad_badge.dart';
import 'ad_cta_button.dart';
import 'ad_design_tokens.dart';
import 'ad_logo_box.dart';
import 'native_ad_data.dart';
import 'native_ad_variant_layout.dart';

class NativeAdVariant1aNoMedia extends StatelessWidget {
  final NativeAdData data;

  const NativeAdVariant1aNoMedia({
    super.key,
    this.data = NativeAdData.dummyNoMedia,
  });

  @override
  Widget build(BuildContext context) {
    return AdScaledCard(
      baseWidth: 345,
      baseHeight: 205,
      builder: (context, scale) {
        final padding = AdDesignTokens.scaledSize(14, scale, min: 10);

        return Stack(
          children: [
            Positioned(
              top: padding,
              right: padding,
              child: AdBadge(scale: scale),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  SizedBox(height: AdDesignTokens.scaledSize(6, scale)),
                  AdLogoBox(
                    logoAsset: data.logoAsset,
                    size: AdDesignTokens.scaledSize(58, scale, min: 44),
                    scale: scale,
                    radius: 11,
                  ),
                  SizedBox(
                    height: AdDesignTokens.scaledSize(13, scale, min: 9),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AdDesignTokens.scaledSize(34, scale, min: 18),
                    ),
                    child: AdTextBlock(
                      data: data,
                      scale: scale,
                      showBadge: false,
                      centered: true,
                      titleMaxLines: 2,
                      bodyMaxLines: 2,
                      titleSize: 15,
                      bodySize: 12,
                    ),
                  ),
                  const Spacer(),
                  AdCtaButton(
                    text: data.cta,
                    scale: scale,
                    width: double.infinity,
                    height: AdDesignTokens.scaledSize(40, scale, min: 32),
                    radius: 9,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
