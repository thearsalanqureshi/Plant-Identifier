import 'package:flutter/material.dart';

import 'ad_cta_button.dart';
import 'ad_design_tokens.dart';
import 'native_ad_data.dart';
import 'native_ad_variant_layout.dart';

class NativeAdVariant8f extends StatelessWidget {
  final NativeAdData data;

  const NativeAdVariant8f({super.key, this.data = NativeAdData.dummyNoMedia});

  @override
  Widget build(BuildContext context) {
    return AdScaledCard(
      baseWidth: 364,
      baseHeight: 116,
      builder: (context, scale) {
        final padding = AdDesignTokens.scaledSize(10, scale, min: 8);

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AdTextBlock(
                  data: data,
                  scale: scale,
                  showBadge: true,
                  badgeBeforeTitle: false,
                  titleMaxLines: 1,
                  bodyMaxLines: 2,
                  titleSize: 13,
                  bodySize: 11,
                ),
              ),
              SizedBox(height: AdDesignTokens.scaledSize(8, scale, min: 6)),
              AdCtaButton(
                text: data.cta,
                scale: scale,
                width: double.infinity,
                height: AdDesignTokens.scaledSize(36, scale, min: 30),
                radius: 9,
              ),
            ],
          ),
        );
      },
    );
  }
}
