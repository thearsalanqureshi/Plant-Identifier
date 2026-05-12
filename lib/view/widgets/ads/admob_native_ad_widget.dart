import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../data/services/ad_service.dart';

class AdMobNativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final String factoryId;
  final String placementName;
  final double? height;
  final Map<String, Object>? customOptions;
  final AdService adService;
  final VoidCallback? onAdLoaded;
  final void Function(LoadAdError error)? onAdFailedToLoad;

  const AdMobNativeAdWidget({
    super.key,
    required this.adUnitId,
    required this.factoryId,
    required this.placementName,
    this.height,
    this.customOptions,
    this.adService = const AdService(),
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  State<AdMobNativeAdWidget> createState() => _AdMobNativeAdWidgetState();
}

class _AdMobNativeAdWidgetState extends State<AdMobNativeAdWidget> {
  static const double _defaultHeight = 180;

  NativeAd? _nativeAd;
  bool _isLoaded = false;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  @override
  void didUpdateWidget(covariant AdMobNativeAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.adUnitId != widget.adUnitId ||
        oldWidget.factoryId != widget.factoryId ||
        oldWidget.placementName != widget.placementName ||
        !mapEquals(oldWidget.customOptions, widget.customOptions)) {
      _disposeCurrentAd();
      _loadNativeAd();
    }
  }

  @override
  void dispose() {
    _loadGeneration++;
    _disposeCurrentAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nativeAd = _nativeAd;
    final adHeight = widget.height ?? _defaultHeight;

    if (!_isLoaded || nativeAd == null || adHeight <= 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: adHeight,
      child: AdWidget(ad: nativeAd),
    );
  }

  void _loadNativeAd() {
    final adUnitId = widget.adUnitId.trim();
    final factoryId = widget.factoryId.trim();

    if (adUnitId.isEmpty || factoryId.isEmpty) {
      debugPrint(
        '[AdMobNativeAdWidget][${widget.placementName}] '
        'Missing native ad unit ID or factory ID.',
      );
      return;
    }

    final generation = ++_loadGeneration;
    final nativeAd = widget.adService.createNativeAd(
      adUnitId: adUnitId,
      factoryId: factoryId,
      placementName: widget.placementName,
      customOptions: _customOptionsWithVariant(factoryId),
      onLoaded: (ad) {
        if (!mounted || generation != _loadGeneration) {
          widget.adService.disposeNativeAd(
            ad,
            placementName: widget.placementName,
          );
          return;
        }

        setState(() {
          _nativeAd = ad;
          _isLoaded = true;
        });
        widget.onAdLoaded?.call();
      },
      onFailedToLoad: (error) {
        if (!mounted || generation != _loadGeneration) {
          return;
        }

        debugPrint(
          '[AdMobNativeAdWidget][${widget.placementName}] '
          'Native ad failed: $error',
        );
        setState(() {
          _nativeAd = null;
          _isLoaded = false;
        });
        widget.onAdFailedToLoad?.call(error);
      },
    );

    _nativeAd = nativeAd;
    _isLoaded = false;
  }

  Map<String, Object>? _customOptionsWithVariant(String factoryId) {
    final customOptions = widget.customOptions;

    if (customOptions == null || customOptions.isEmpty) {
      return <String, Object>{'variant': factoryId};
    }

    return <String, Object>{
      ...customOptions,
      if (!customOptions.containsKey('variant')) 'variant': factoryId,
    };
  }

  void _disposeCurrentAd() {
    widget.adService.disposeNativeAd(
      _nativeAd,
      placementName: widget.placementName,
    );
    _nativeAd = null;
    _isLoaded = false;
  }
}
