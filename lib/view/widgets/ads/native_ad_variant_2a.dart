import 'package:flutter/material.dart';

import 'ad_cta_button.dart';
import 'ad_design_tokens.dart';
import 'ad_logo_box.dart';
import 'ad_media_view.dart';
import 'native_ad_data.dart';
import 'native_ad_variant_layout.dart';

class NativeAdVariant2a extends StatelessWidget {
  final NativeAdData data;

  const NativeAdVariant2a({super.key, this.data = NativeAdData.dummy});

  @override
  Widget build(BuildContext context) {
    return AdScaledCard(
      baseWidth: 364,
      baseHeight: 273,
      builder: (context, scale) {
        final padding = AdDesignTokens.scaledSize(10, scale, min: 8);
        final gap = AdDesignTokens.scaledSize(8, scale, min: 6);

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdLogoBox(
                    logoAsset: data.logoAsset,
                    size: AdDesignTokens.scaledSize(43, scale, min: 34),
                    scale: scale,
                    radius: 9,
                  ),
                  SizedBox(width: AdDesignTokens.scaledSize(10, scale, min: 8)),
                  Expanded(
                    child: AdTextBlock(
                      data: data,
                      scale: scale,
                      titleMaxLines: 1,
                      bodyMaxLines: 2,
                      titleSize: 14,
                      bodySize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),
              Expanded(
                child: AdMediaView(
                  asset: NativeAdData.native2aMediaAsset,
                  scale: scale,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(
                    AdDesignTokens.scaledSize(10, scale, min: 8),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: gap),
              AdCtaButton(
                text: data.cta,
                scale: scale,
                width: double.infinity,
                height: AdDesignTokens.scaledSize(39, scale, min: 32),
                radius: 9,
              ),
            ],
          ),
        );
      },
    );
  }
}
