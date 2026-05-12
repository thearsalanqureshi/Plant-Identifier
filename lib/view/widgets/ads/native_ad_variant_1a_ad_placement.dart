import 'package:flutter/material.dart';

import 'ad_badge.dart';
import 'ad_cta_button.dart';
import 'ad_design_tokens.dart';
import 'ad_logo_box.dart';
import 'ad_media_view.dart';
import 'native_ad_data.dart';
import 'native_ad_variant_layout.dart';

class NativeAdVariant1aAdPlacement extends StatelessWidget {
  final NativeAdData data;

  const NativeAdVariant1aAdPlacement({
    super.key,
    this.data = NativeAdData.dummy,
  });

  @override
  Widget build(BuildContext context) {
    return AdScaledCard(
      baseWidth: 345,
      baseHeight: 205,
      builder: (context, scale) {
        final padding = AdDesignTokens.scaledSize(12, scale, min: 9);
        final gap = AdDesignTokens.scaledSize(10, scale, min: 7);

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: AdDesignTokens.scaledSize(196, scale, min: 154),
                      child: AdMediaView(
                        asset: NativeAdData.native1aMediaAsset,
                        scale: scale,
                        borderRadius: BorderRadius.circular(
                          AdDesignTokens.scaledSize(10, scale, min: 8),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AdLogoBox(
                                logoAsset: data.logoAsset,
                                size: AdDesignTokens.scaledSize(
                                  44,
                                  scale,
                                  min: 34,
                                ),
                                scale: scale,
                                radius: 9,
                              ),
                              const Spacer(),
                              AdBadge(scale: scale),
                            ],
                          ),
                          SizedBox(
                            height: AdDesignTokens.scaledSize(9, scale, min: 6),
                          ),
                          AdTextBlock(
                            data: data,
                            scale: scale,
                            showBadge: false,
                            titleMaxLines: 2,
                            bodyMaxLines: 3,
                            titleSize: 13,
                            bodySize: 11,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: gap),
              AdCtaButton(
                text: data.cta,
                scale: scale,
                width: double.infinity,
                height: AdDesignTokens.scaledSize(40, scale, min: 32),
                radius: 9,
              ),
            ],
          ),
        );
      },
    );
  }
}
