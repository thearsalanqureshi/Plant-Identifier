import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../view_models/ad_config_view_model.dart';
import '../../view_models/ad_view_model.dart';

bool _isShiftInterstitialFlowRunning = false;

Future<void> runWithShiftInterstitial({
  required BuildContext context,
  required FutureOr<void> Function() action,
  bool isExcludedButton = false,
  String placementName = 'shift_interstitial',
}) async {
  var didRunAction = false;

  Future<void> runActionOnce() async {
    if (didRunAction) {
      return;
    }

    didRunAction = true;

    if (!context.mounted) {
      return;
    }

    try {
      await action();
    } catch (error) {
      debugPrint('[AdNavigationHelper][$placementName] Action failed: $error');
    }
  }

  if (isExcludedButton) {
    await runActionOnce();
    return;
  }

  if (_isShiftInterstitialFlowRunning) {
    debugPrint(
      '[AdNavigationHelper][$placementName] Shift interstitial flow already '
      'running; duplicate tap ignored.',
    );
    return;
  }

  _isShiftInterstitialFlowRunning = true;

  try {
    final adConfigViewModel = context.read<AdConfigViewModel>();
    final adViewModel = context.read<AdViewModel>();
    final config = adConfigViewModel.config;

    if (config.shiftInterstitialAdId.trim().isEmpty ||
        adViewModel.isFullScreenAdShowing) {
      await runActionOnce();
      return;
    }

    final shouldShowAd = adViewModel.shouldShowShiftInterstitial(
      config: config,
      isExcludedButton: false,
    );

    if (!shouldShowAd) {
      await runActionOnce();
      return;
    }

    final loaderSeconds = config.loaderTimerSeconds <= 0
        ? 2
        : config.loaderTimerSeconds;

    adViewModel.showAdLoader();

    try {
      await adViewModel
          .loadShiftInterstitial(config)
          .timeout(Duration(seconds: loaderSeconds));
    } on TimeoutException {
      debugPrint(
        '[AdNavigationHelper][$placementName] Shift interstitial load timed '
        'out.',
      );
    } catch (error) {
      debugPrint(
        '[AdNavigationHelper][$placementName] Shift interstitial load failed: '
        '$error',
      );
    } finally {
      adViewModel.hideAdLoader();
    }

    if (!context.mounted) {
      return;
    }

    if (!adViewModel.hasShiftInterstitial) {
      await runActionOnce();
      return;
    }

    await adViewModel.showShiftInterstitial(
      onDismissed: () => unawaited(runActionOnce()),
      onFailedToShow: () => unawaited(runActionOnce()),
    );
  } finally {
    _isShiftInterstitialFlowRunning = false;
  }
}
