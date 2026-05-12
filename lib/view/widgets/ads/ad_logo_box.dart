import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'ad_design_tokens.dart';

class AdLogoBox extends StatelessWidget {
  final String? logoAsset;
  final double size;
  final double scale;
  final double radius;

  const AdLogoBox({
    super.key,
    required this.logoAsset,
    required this.size,
    required this.scale,
    this.radius = 9,
  });

  @override
  Widget build(BuildContext context) {
    final actualRadius = AdDesignTokens.scaledSize(radius, scale, min: 6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(actualRadius),
      child: ColoredBox(
        color: AdDesignTokens.logoBackground,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: _LogoAsset(logoAsset: logoAsset, size: size, scale: scale),
          ),
        ),
      ),
    );
  }
}

class _LogoAsset extends StatelessWidget {
  final String? logoAsset;
  final double size;
  final double scale;

  const _LogoAsset({
    required this.logoAsset,
    required this.size,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final asset = logoAsset;
    final imageSize = size * 0.68;

    if (asset == null || asset.isEmpty) {
      return Text(
        'e',
        style: TextStyle(
          color: AdDesignTokens.white,
          fontFamily: AdDesignTokens.fontFamily,
          fontSize: AdDesignTokens.scaledFont(20, scale, min: 14),
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: 0,
        ),
      );
    }

    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
        colorFilter: null,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            _pngFallbackPath(asset),
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
          );
        },
      );
    }

    return Image.asset(
      asset,
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
    );
  }

  String _pngFallbackPath(String svgAsset) {
    return svgAsset.replaceFirst(
      RegExp(r'\.svg$', caseSensitive: false),
      '.png',
    );
  }
}
