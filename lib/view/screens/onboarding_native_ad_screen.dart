import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../widgets/ads/admob_native_ad_widget.dart';

class OnboardingNativeAdScreen extends StatefulWidget {
  final String adUnitId;
  final String factoryId;
  final String variant;
  final String ctaColor;
  final String textColor;

  const OnboardingNativeAdScreen({
    super.key,
    required this.adUnitId,
    required this.factoryId,
    required this.variant,
    required this.ctaColor,
    required this.textColor,
  });

  @override
  State<OnboardingNativeAdScreen> createState() =>
      _OnboardingNativeAdScreenState();
}

class _OnboardingNativeAdScreenState extends State<OnboardingNativeAdScreen> {
  static const Duration _loadTimeout = Duration(seconds: 5);

  Timer? _loadTimeoutTimer;
  bool _hasFinished = false;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTimeoutTimer = Timer(_loadTimeout, () {
      if (!_isAdLoaded) {
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.shortestSide >= 600;
    final adHeight = (screenSize.height * (isTablet ? 0.56 : 0.58))
        .clamp(260.0, isTablet ? 560.0 : 430.0)
        .toDouble();
    final maxContentWidth = isTablet ? 620.0 : 430.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _finish,
                    icon: const Icon(Icons.close),
                    color: AppColors.black,
                    tooltip: 'Close',
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AdMobNativeAdWidget(
                        adUnitId: widget.adUnitId,
                        factoryId: widget.factoryId,
                        placementName: 'onboarding_full_screen_native',
                        height: adHeight,
                        customOptions: {
                          'ctaColor': widget.ctaColor,
                          'textColor': widget.textColor,
                          'variant': widget.variant,
                        },
                        onAdLoaded: _handleAdLoaded,
                        onAdFailedToLoad: (_) => _finish(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 16,
                    12,
                    isTablet ? 32 : 16,
                    isTablet ? 24 : 16,
                  ),
                  child: SizedBox(
                    width: isTablet ? 400 : double.infinity,
                    height: isTablet ? 58 : 56,
                    child: ElevatedButton(
                      onPressed: _finish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: AppTypography.buttonText.copyWith(
                          fontFamily: 'DMSans',
                          fontSize: isTablet ? 18 : 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAdLoaded() {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _isAdLoaded = true;
    });
  }

  void _finish() {
    if (_hasFinished) {
      return;
    }

    _hasFinished = true;
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = null;

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
