import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../data/models/ad_config_model.dart';
import '../../../data/services/ad_service.dart';
import '../../../view_models/ad_config_view_model.dart';

class AdaptiveBannerAdWidget extends StatelessWidget {
  final AdService adService;
  final String placementName;

  const AdaptiveBannerAdWidget({
    super.key,
    this.adService = const AdService(),
    this.placementName = 'main_banner',
  });

  @override
  Widget build(BuildContext context) {
    final bannerConfig = context.select<AdConfigViewModel, _BannerConfig>(
      (viewModel) => _BannerConfig.fromAdConfig(viewModel.config),
    );

    if (!bannerConfig.isEnabled) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackWidth;
        final bannerWidth = availableWidth.floor();

        if (bannerWidth <= 0) {
          return const SizedBox.shrink();
        }

        return _AdaptiveBannerAdSlot(
          adService: adService,
          bannerConfig: bannerConfig,
          placementName: placementName,
          width: bannerWidth,
        );
      },
    );
  }
}

class _AdaptiveBannerAdSlot extends StatefulWidget {
  final AdService adService;
  final _BannerConfig bannerConfig;
  final String placementName;
  final int width;

  const _AdaptiveBannerAdSlot({
    required this.adService,
    required this.bannerConfig,
    required this.placementName,
    required this.width,
  });

  @override
  State<_AdaptiveBannerAdSlot> createState() => _AdaptiveBannerAdSlotState();
}

class _AdaptiveBannerAdSlotState extends State<_AdaptiveBannerAdSlot> {
  BannerAd? _bannerAd;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void didUpdateWidget(covariant _AdaptiveBannerAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.width != widget.width ||
        oldWidget.bannerConfig != widget.bannerConfig ||
        oldWidget.placementName != widget.placementName) {
      _disposeCurrentBanner();
      _loadBanner();
    }
  }

  @override
  void dispose() {
    _loadGeneration++;
    _disposeCurrentBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;

    if (bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: bannerAd.size.width.toDouble(),
        height: bannerAd.size.height.toDouble(),
        child: AdWidget(ad: bannerAd),
      ),
    );
  }

  Future<void> _loadBanner() async {
    final generation = ++_loadGeneration;

    final bannerAd = await widget.adService.createAdaptiveBannerAd(
      adUnitId: widget.bannerConfig.adUnitId,
      width: widget.width,
      placementName: widget.placementName,
      collapsible: widget.bannerConfig.isCollapsible,
      onFailedToLoad: (error) {
        debugPrint(
          '[AdaptiveBannerAdWidget][${widget.placementName}] '
          'Banner failed: $error',
        );
      },
    );

    if (!mounted || generation != _loadGeneration) {
      widget.adService.disposeBannerAd(
        bannerAd,
        placementName: widget.placementName,
      );
      return;
    }

    setState(() {
      _bannerAd = bannerAd;
    });
  }

  void _disposeCurrentBanner() {
    widget.adService.disposeBannerAd(
      _bannerAd,
      placementName: widget.placementName,
    );
    _bannerAd = null;
  }
}

class _BannerConfig {
  final bool isAdsMasterEnabled;
  final bool bannerEnabled;
  final String adUnitId;
  final String bannerType;

  const _BannerConfig({
    required this.isAdsMasterEnabled,
    required this.bannerEnabled,
    required this.adUnitId,
    required this.bannerType,
  });

  factory _BannerConfig.fromAdConfig(AdConfigModel config) {
    return _BannerConfig(
      isAdsMasterEnabled: config.isAdsMasterEnabled,
      bannerEnabled: config.bannerEnabled,
      adUnitId: config.bannerAdId.trim(),
      bannerType: config.bannerType.trim().toLowerCase(),
    );
  }

  bool get isEnabled =>
      isAdsMasterEnabled && bannerEnabled && adUnitId.isNotEmpty;

  bool get isCollapsible => bannerType == 'collapsible';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _BannerConfig &&
            other.isAdsMasterEnabled == isAdsMasterEnabled &&
            other.bannerEnabled == bannerEnabled &&
            other.adUnitId == adUnitId &&
            other.bannerType == bannerType;
  }

  @override
  int get hashCode =>
      Object.hash(isAdsMasterEnabled, bannerEnabled, adUnitId, bannerType);
}
