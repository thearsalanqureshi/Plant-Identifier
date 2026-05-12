import 'package:flutter/material.dart';

import 'ad_cta_button.dart';
import 'ad_design_tokens.dart';
import 'ad_logo_box.dart';
import 'ad_media_view.dart';
import 'native_ad_data.dart';
import 'native_ad_variant_layout.dart';

class NativeAdVariant9 extends StatelessWidget {
  final NativeAdData data;

  const NativeAdVariant9({super.key, this.data = NativeAdData.dummy});

  @override
  Widget build(BuildContext context) {
    return AdScaledCard(
      baseWidth: 364,
      baseHeight: 228,
      builder: (context, scale) {
        final padding = AdDesignTokens.scaledSize(10, scale, min: 8);

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              SizedBox(
                height: AdDesignTokens.scaledSize(154, scale, min: 118),
                width: double.infinity,
                child: AdMediaView(
                  asset: NativeAdData.native2aMediaAsset,
                  scale: scale,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: AdDesignTokens.scaledSize(8, scale, min: 6)),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    SizedBox(
                      width: AdDesignTokens.scaledSize(8, scale, min: 6),
                    ),
                    AdCtaButton(
                      text: data.cta,
                      scale: scale,
                      width: AdDesignTokens.scaledSize(82, scale, min: 70),
                      height: AdDesignTokens.scaledSize(34, scale, min: 30),
                      radius: 17,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
