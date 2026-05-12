import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../data/models/ad_config_model.dart';
import '../../../view_models/ad_config_view_model.dart';
import '../../../view_models/ad_view_model.dart';

class AppOpenAdLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppOpenAdLifecycleHandler({super.key, required this.child});

  @override
  State<AppOpenAdLifecycleHandler> createState() =>
      _AppOpenAdLifecycleHandlerState();
}

class _AppOpenAdLifecycleHandlerState extends State<AppOpenAdLifecycleHandler>
    with WidgetsBindingObserver {
  bool _hasMovedToBackground = false;
  bool _isHandlingResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_loadForFutureResume());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isFullScreenAdCurrentlyShowing()) {
        return;
      }

      _hasMovedToBackground = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _hasMovedToBackground) {
      _hasMovedToBackground = false;
      unawaited(_handleForegroundResume());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _handleForegroundResume() async {
    if (_isHandlingResume || !mounted) {
      return;
    }

    _isHandlingResume = true;

    try {
      final config = await _readInitializedConfig();
      if (config == null || !mounted) {
        return;
      }

      final adViewModel = context.read<AdViewModel>();

      if (!_canUseAppOpenAds(config, adViewModel)) {
        return;
      }

      if (!adViewModel.hasAppOpenAd) {
        await adViewModel.loadAppOpenAd(config);
        return;
      }

      await adViewModel.showAppOpenAd(
        onDismissed: () => unawaited(_loadForFutureResume()),
        onFailedToShow: () => unawaited(_loadForFutureResume()),
      );
    } catch (error) {
      debugPrint('[AppOpenAdLifecycleHandler] Resume handling failed: $error');
    } finally {
      _isHandlingResume = false;
    }
  }

  Future<void> _loadForFutureResume() async {
    if (!mounted) {
      return;
    }

    try {
      final config = await _readInitializedConfig();
      if (config == null || !mounted) {
        return;
      }

      final adViewModel = context.read<AdViewModel>();

      if (!config.isAdsMasterEnabled ||
          !config.appOpenEnabled ||
          config.appOpenAdId.trim().isEmpty ||
          adViewModel.isFullScreenAdShowing ||
          adViewModel.hasAppOpenAd) {
        return;
      }

      await adViewModel.loadAppOpenAd(config);
    } catch (error) {
      debugPrint('[AppOpenAdLifecycleHandler] App open preload failed: $error');
    }
  }

  Future<AdConfigModel?> _readInitializedConfig() async {
    if (!mounted) {
      return null;
    }

    final adConfigViewModel = context.read<AdConfigViewModel>();

    if (!adConfigViewModel.isInitialized) {
      try {
        await adConfigViewModel.initialize();
      } catch (error) {
        debugPrint(
          '[AppOpenAdLifecycleHandler] Config initialization failed: $error',
        );
      }
    }

    if (!mounted) {
      return null;
    }

    return adConfigViewModel.config;
  }

  bool _canUseAppOpenAds(AdConfigModel config, AdViewModel adViewModel) {
    return config.isAdsMasterEnabled &&
        config.appOpenEnabled &&
        config.appOpenAdId.trim().isNotEmpty &&
        !adViewModel.isFullScreenAdShowing;
  }

  bool _isFullScreenAdCurrentlyShowing() {
    if (!mounted) {
      return false;
    }

    try {
      return context.read<AdViewModel>().isFullScreenAdShowing;
    } catch (error) {
      debugPrint(
        '[AppOpenAdLifecycleHandler] Full-screen lock check failed: $error',
      );
      return false;
    }
  }
}
