import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  const AdService();

  Future<InterstitialAd?> loadInterstitialAd({
    required String adUnitId,
    required String placementName,
  }) async {
    if (!_hasAdUnitId(adUnitId, placementName, 'interstitial')) {
      return null;
    }

    final completer = Completer<InterstitialAd?>();

    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[AdService][$placementName] Interstitial loaded.');
            _completeIfPending(completer, ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint(
              '[AdService][$placementName] Interstitial failed to load: $error',
            );
            _completeIfPending(completer, null);
          },
        ),
      );
    } catch (error) {
      debugPrint('[AdService][$placementName] Interstitial load error: $error');
      _completeIfPending(completer, null);
    }

    return completer.future;
  }

  Future<void> showInterstitialAd({
    required InterstitialAd? ad,
    required String placementName,
    VoidCallback? onShowed,
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
  }) async {
    if (ad == null) {
      debugPrint('[AdService][$placementName] Interstitial is null.');
      _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
      return;
    }

    var terminalCallbackHandled = false;

    void handleDismissed(InterstitialAd dismissedAd) {
      if (terminalCallbackHandled) {
        return;
      }
      terminalCallbackHandled = true;
      debugPrint('[AdService][$placementName] Interstitial dismissed.');
      disposeInterstitialAd(dismissedAd, placementName: placementName);
      _safeVoidCallback(onDismissed, placementName, 'onDismissed');
    }

    void handleFailedToShow(InterstitialAd failedAd, Object error) {
      if (terminalCallbackHandled) {
        return;
      }
      terminalCallbackHandled = true;
      debugPrint(
        '[AdService][$placementName] Interstitial failed to show: $error',
      );
      disposeInterstitialAd(failedAd, placementName: placementName);
      _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (_) {
        debugPrint('[AdService][$placementName] Interstitial showed.');
        _safeVoidCallback(onShowed, placementName, 'onShowed');
      },
      onAdDismissedFullScreenContent: handleDismissed,
      onAdFailedToShowFullScreenContent: handleFailedToShow,
    );

    try {
      await ad.show();
    } catch (error) {
      handleFailedToShow(ad, error);
    }
  }

  Future<RewardedInterstitialAd?> loadRewardedInterstitialAd({
    required String adUnitId,
    required String placementName,
  }) async {
    if (!_hasAdUnitId(adUnitId, placementName, 'rewarded interstitial')) {
      return null;
    }

    final completer = Completer<RewardedInterstitialAd?>();

    try {
      await RewardedInterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint(
              '[AdService][$placementName] Rewarded interstitial loaded.',
            );
            _completeIfPending(completer, ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint(
              '[AdService][$placementName] Rewarded interstitial failed to '
              'load: $error',
            );
            _completeIfPending(completer, null);
          },
        ),
      );
    } catch (error) {
      debugPrint(
        '[AdService][$placementName] Rewarded interstitial load error: $error',
      );
      _completeIfPending(completer, null);
    }

    return completer.future;
  }

  Future<void> showRewardedInterstitialAd({
    required RewardedInterstitialAd? ad,
    required String placementName,
    VoidCallback? onShowed,
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
    void Function(RewardItem reward)? onUserEarnedReward,
  }) async {
    if (ad == null) {
      debugPrint('[AdService][$placementName] Rewarded interstitial is null.');
      _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
      return;
    }

    var terminalCallbackHandled = false;

    void handleDismissed(RewardedInterstitialAd dismissedAd) {
      if (terminalCallbackHandled) {
        return;
      }
      terminalCallbackHandled = true;
      debugPrint(
        '[AdService][$placementName] Rewarded interstitial dismissed.',
      );
      disposeRewardedInterstitialAd(dismissedAd, placementName: placementName);
      _safeVoidCallback(onDismissed, placementName, 'onDismissed');
    }

    void handleFailedToShow(RewardedInterstitialAd failedAd, Object error) {
      if (terminalCallbackHandled) {
        return;
      }
      terminalCallbackHandled = true;
      debugPrint(
        '[AdService][$placementName] Rewarded interstitial failed to show: '
        '$error',
      );
      disposeRewardedInterstitialAd(failedAd, placementName: placementName);
      _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
    }

    ad.fullScreenContentCallback =
        FullScreenContentCallback<RewardedInterstitialAd>(
          onAdShowedFullScreenContent: (_) {
            debugPrint(
              '[AdService][$placementName] Rewarded interstitial showed.',
            );
            _safeVoidCallback(onShowed, placementName, 'onShowed');
          },
          onAdDismissedFullScreenContent: handleDismissed,
          onAdFailedToShowFullScreenContent: handleFailedToShow,
        );

    try {
      await ad.show(
        onUserEarnedReward: (_, reward) {
          debugPrint(
            '[AdService][$placementName] Reward earned: '
            '${reward.amount} ${reward.type}',
          );
          _safeRewardCallback(
            onUserEarnedReward,
            reward,
            placementName,
            'onUserEarnedReward',
          );
        },
      );
    } catch (error) {
      handleFailedToShow(ad, error);
    }
  }

  Future<AppOpenAd?> loadAppOpenAd({
    required String adUnitId,
    required String placementName,
  }) async {
    if (!_hasAdUnitId(adUnitId, placementName, 'app open')) {
      return null;
    }

    final completer = Completer<AppOpenAd?>();

    try {
      await AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[AdService][$placementName] App open ad loaded.');
            _completeIfPending(completer, ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint(
              '[AdService][$placementName] App open ad failed to load: $error',
            );
            _completeIfPending(completer, null);
          },
        ),
      );
    } catch (error) {
      debugPrint('[AdService][$placementName] App open load error: $error');
      _completeIfPending(completer, null);
    }

    return completer.future;
  }

  Future<void> showAppOpenAd({
    required AppOpenAd? ad,
    required String placementName,
    VoidCallback? onShowed,
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
  }) async {
    if (ad == null) {
      debugPrint('[AdService][$placementName] App open ad is null.');
      _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
      return;
    }

    var terminalCallbackHandled = false;

    void handleDismissed(AppOpenAd dismissedAd) {
      if (terminalCallbackHandled) {
        return;
      }
      terminalCallbackHandled = true;
      debugPrint('[AdService][$placementName] App open ad dismissed.');
      disposeAppOpenAd(dismissedAd, placementName: placementName);
      _safeVoidCallback(onDismissed, placementName, 'onDismissed');
    }

    void handleFailedToShow(AppOpenAd failedAd, Object error) {
      if (terminalCallbackHandled) {
        return;
      }
      terminalCallbackHandled = true;
      debugPrint(
        '[AdService][$placementName] App open ad failed to show: $error',
      );
      disposeAppOpenAd(failedAd, placementName: placementName);
      _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdShowedFullScreenContent: (_) {
        debugPrint('[AdService][$placementName] App open ad showed.');
        _safeVoidCallback(onShowed, placementName, 'onShowed');
      },
      onAdDismissedFullScreenContent: handleDismissed,
      onAdFailedToShowFullScreenContent: handleFailedToShow,
    );

    try {
      await ad.show();
    } catch (error) {
      handleFailedToShow(ad, error);
    }
  }

  Future<BannerAd?> createAdaptiveBannerAd({
    required String adUnitId,
    required int width,
    required String placementName,
    bool collapsible = false,
    void Function(BannerAd ad)? onLoaded,
    void Function(LoadAdError error)? onFailedToLoad,
  }) async {
    if (!_hasAdUnitId(adUnitId, placementName, 'banner')) {
      return null;
    }

    if (width <= 0) {
      debugPrint('[AdService][$placementName] Invalid banner width: $width');
      return null;
    }

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (size == null) {
      debugPrint(
        '[AdService][$placementName] Adaptive banner size unavailable.',
      );
      return null;
    }

    final completer = Completer<BannerAd?>();
    late final BannerAd bannerAd;

    bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: _adRequest(collapsible: collapsible),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          final loadedAd = ad is BannerAd ? ad : bannerAd;
          debugPrint(
            '[AdService][$placementName] Banner loaded '
            '(${size.width}x${size.height}).',
          );
          _safeBannerCallback(onLoaded, loadedAd, placementName, 'onLoaded');
          _completeIfPending(completer, loadedAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            '[AdService][$placementName] Banner failed to load: $error',
          );
          ad.dispose();
          _safeLoadErrorCallback(
            onFailedToLoad,
            error,
            placementName,
            'onFailedToLoad',
          );
          _completeIfPending(completer, null);
        },
      ),
    );

    try {
      await bannerAd.load();
    } catch (error) {
      debugPrint('[AdService][$placementName] Banner load error: $error');
      disposeBannerAd(bannerAd, placementName: placementName);
      _completeIfPending(completer, null);
    }

    return completer.future;
  }

  NativeAd createNativeAd({
    required String adUnitId,
    required String factoryId,
    required String placementName,
    Map<String, Object>? customOptions,
    void Function(NativeAd ad)? onLoaded,
    void Function(LoadAdError error)? onFailedToLoad,
  }) {
    late final NativeAd nativeAd;

    nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: factoryId,
      customOptions: customOptions,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          final loadedAd = ad is NativeAd ? ad : nativeAd;
          debugPrint('[AdService][$placementName] Native ad loaded.');
          _safeNativeCallback(onLoaded, loadedAd, placementName, 'onLoaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            '[AdService][$placementName] Native ad failed to load: $error',
          );
          ad.dispose();
          _safeLoadErrorCallback(
            onFailedToLoad,
            error,
            placementName,
            'onFailedToLoad',
          );
        },
      ),
    );

    unawaited(
      nativeAd.load().catchError((Object error) {
        debugPrint('[AdService][$placementName] Native ad load error: $error');
        disposeNativeAd(nativeAd, placementName: placementName);
      }),
    );

    return nativeAd;
  }

  void disposeInterstitialAd(
    InterstitialAd? ad, {
    String placementName = 'unknown',
  }) {
    _safeDispose(ad, placementName, 'interstitial');
  }

  void disposeRewardedInterstitialAd(
    RewardedInterstitialAd? ad, {
    String placementName = 'unknown',
  }) {
    _safeDispose(ad, placementName, 'rewarded interstitial');
  }

  void disposeAppOpenAd(AppOpenAd? ad, {String placementName = 'unknown'}) {
    _safeDispose(ad, placementName, 'app open');
  }

  void disposeBannerAd(BannerAd? ad, {String placementName = 'unknown'}) {
    _safeDispose(ad, placementName, 'banner');
  }

  void disposeNativeAd(NativeAd? ad, {String placementName = 'unknown'}) {
    _safeDispose(ad, placementName, 'native');
  }

  AdRequest _adRequest({bool collapsible = false}) {
    if (!collapsible) {
      return const AdRequest();
    }

    return const AdRequest(extras: {'collapsible': 'bottom'});
  }

  bool _hasAdUnitId(String adUnitId, String placementName, String adType) {
    if (adUnitId.trim().isNotEmpty) {
      return true;
    }

    debugPrint('[AdService][$placementName] Missing $adType ad unit ID.');
    return false;
  }

  void _safeDispose(Ad? ad, String placementName, String adType) {
    if (ad == null) {
      return;
    }

    try {
      ad.dispose();
    } catch (error) {
      debugPrint(
        '[AdService][$placementName] Failed to dispose $adType ad: $error',
      );
    }
  }

  void _safeVoidCallback(
    VoidCallback? callback,
    String placementName,
    String callbackName,
  ) {
    if (callback == null) {
      return;
    }

    try {
      callback();
    } catch (error) {
      debugPrint(
        '[AdService][$placementName] Callback $callbackName failed: $error',
      );
    }
  }

  void _safeRewardCallback(
    void Function(RewardItem reward)? callback,
    RewardItem reward,
    String placementName,
    String callbackName,
  ) {
    if (callback == null) {
      return;
    }

    try {
      callback(reward);
    } catch (error) {
      debugPrint(
        '[AdService][$placementName] Callback $callbackName failed: $error',
      );
    }
  }

  void _safeBannerCallback(
    void Function(BannerAd ad)? callback,
    BannerAd ad,
    String placementName,
    String callbackName,
  ) {
    if (callback == null) {
      return;
    }

    try {
      callback(ad);
    } catch (error) {
      debugPrint(
        '[AdService][$placementName] Callback $callbackName failed: $error',
      );
    }
  }

  void _safeNativeCallback(
    void Function(NativeAd ad)? callback,
    NativeAd ad,
    String placementName,
    String callbackName,
  ) {
    if (callback == null) {
      return;
    }

    try {
      callback(ad);
    } catch (error) {
      debugPrint(
        '[AdService][$placementName] Callback $callbackName failed: $error',
      );
    }
  }

  void _safeLoadErrorCallback(
    void Function(LoadAdError error)? callback,
    LoadAdError error,
    String placementName,
    String callbackName,
  ) {
    if (callback == null) {
      return;
    }

    try {
      callback(error);
    } catch (callbackError) {
      debugPrint(
        '[AdService][$placementName] Callback $callbackName failed: '
        '$callbackError',
      );
    }
  }

  void _completeIfPending<T>(Completer<T> completer, T value) {
    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }
}
