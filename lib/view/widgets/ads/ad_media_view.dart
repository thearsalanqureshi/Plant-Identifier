import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'ad_design_tokens.dart';

class AdMediaView extends StatelessWidget {
  final String? asset;
  final double scale;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final Widget? overlay;

  const AdMediaView({
    super.key,
    required this.asset,
    required this.scale,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: AdDesignTokens.backgroundBlue,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _MediaAsset(asset: asset, scale: scale, fit: fit),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}

class _MediaAsset extends StatelessWidget {
  final String? asset;
  final double scale;
  final BoxFit fit;

  const _MediaAsset({
    required this.asset,
    required this.scale,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final imageAsset = asset;

    if (imageAsset == null || imageAsset.isEmpty) {
      return Center(
        child: Icon(
          Icons.image_outlined,
          color: AdDesignTokens.mainText,
          size: AdDesignTokens.scaledSize(28, scale, min: 18),
        ),
      );
    }

    if (imageAsset.toLowerCase().endsWith('.svg')) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _pngFallbackPath(imageAsset),
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
          SvgPicture.asset(
            imageAsset,
            fit: fit,
            colorFilter: null,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
        ],
      );
    }

    return Image.asset(imageAsset, fit: fit);
  }

  String _pngFallbackPath(String svgAsset) {
    return svgAsset.replaceFirst(
      RegExp(r'\.svg$', caseSensitive: false),
      '.png',
    );
  }
}
