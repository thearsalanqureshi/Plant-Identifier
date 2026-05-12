import 'package:flutter/material.dart';

import 'ad_cta_button.dart';
import 'ad_design_tokens.dart';
import 'ad_logo_box.dart';
import 'ad_media_view.dart';
import 'native_ad_data.dart';
import 'native_ad_variant_layout.dart';

class NativeAdVariant6c extends StatelessWidget {
  final NativeAdData data;

  const NativeAdVariant6c({super.key, this.data = NativeAdData.dummy});

  @override
  Widget build(BuildContext context) {
    return AdScaledCard(
      baseWidth: 364,
      baseHeight: 273,
      backgroundColor: AdDesignTokens.white,
      builder: (context, scale) {
        final padding = AdDesignTokens.scaledSize(10, scale, min: 8);

        return Column(
          children: [
            SizedBox(
              height: AdDesignTokens.scaledSize(154, scale, min: 120),
              child: AdMediaView(
                asset: NativeAdData.native5aMediaAsset,
                scale: scale,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdLogoBox(
                          logoAsset: data.logoAsset,
                          size: AdDesignTokens.scaledSize(42, scale, min: 34),
                          scale: scale,
                          radius: 8,
                        ),
                        SizedBox(
                          width: AdDesignTokens.scaledSize(10, scale, min: 8),
                        ),
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
                      ],
                    ),
                    const Spacer(),
                    AdCtaButton(
                      text: data.cta,
                      scale: scale,
                      width: double.infinity,
                      height: AdDesignTokens.scaledSize(38, scale, min: 31),
                      radius: 9,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
