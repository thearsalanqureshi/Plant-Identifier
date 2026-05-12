import 'package:flutter/material.dart';

import 'ad_design_tokens.dart';
import 'ad_logo_box.dart';
import 'native_ad_data.dart';
import 'native_ad_variant_layout.dart';

class NativeAdVariant3b extends StatelessWidget {
  final NativeAdData data;

  const NativeAdVariant3b({super.key, this.data = NativeAdData.dummy});

  @override
  Widget build(BuildContext context) {
    return AdScaledCard(
      baseWidth: 364,
      baseHeight: 66,
      radius: 0,
      builder: (context, scale) {
        final padding = AdDesignTokens.scaledSize(10, scale, min: 8);

        return Row(
          children: [
            SizedBox(width: padding),
            AdLogoBox(
              logoAsset: data.logoAsset,
              size: AdDesignTokens.scaledSize(42, scale, min: 34),
              scale: scale,
              radius: 8,
            ),
            SizedBox(width: AdDesignTokens.scaledSize(10, scale, min: 8)),
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
            SizedBox(width: AdDesignTokens.scaledSize(8, scale, min: 6)),
            SizedBox(
              width: AdDesignTokens.scaledSize(88, scale, min: 76),
              child: SizedBox.expand(
                child: AdCtaPanel(text: data.cta, scale: scale),
              ),
            ),
          ],
        );
      },
    );
  }
}
