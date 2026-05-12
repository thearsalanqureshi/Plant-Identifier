import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../data/models/ad_config_model.dart';
import '../data/services/ad_service.dart';

class AdViewModel extends ChangeNotifier {
  final AdService _adService;

  bool _isFullScreenAdShowing = false;
  bool _isAdLoaderVisible = false;
  Timer? _loaderTimer;

  int _shiftInterstitialClickCount = 0;
  DateTime? _lastShiftInterstitialShownAt;

  InterstitialAd? _splashInterstitialAd;
  InterstitialAd? _shiftInterstitialAd;
  RewardedInterstitialAd? _rewardedInterstitialAfterPremiumAd;
  AppOpenAd? _appOpenAd;

  bool _isLoadingSplashInterstitial = false;
  bool _isLoadingShiftInterstitial = false;
  bool _isLoadingRewardedInterstitialAfterPremium = false;
  bool _isLoadingAppOpenAd = false;

  AdViewModel({AdService? adService})
    : _adService = adService ?? const AdService();

  bool get isFullScreenAdShowing => _isFullScreenAdShowing;
  bool get isAdLoaderVisible => _isAdLoaderVisible;
  int get shiftInterstitialClickCount => _shiftInterstitialClickCount;
  DateTime? get lastShiftInterstitialShownAt => _lastShiftInterstitialShownAt;

  bool get hasSplashInterstitial => _splashInterstitialAd != null;
  bool get hasShiftInterstitial => _shiftInterstitialAd != null;
  bool get hasRewardedInterstitialAfterPremium =>
      _rewardedInterstitialAfterPremiumAd != null;
  bool get hasAppOpenAd => _appOpenAd != null;

  void showAdLoader() {
    _setAdLoaderVisible(true);
  }

  void hideAdLoader() {
    _loaderTimer?.cancel();
    _loaderTimer = null;
    _setAdLoaderVisible(false);
  }

  void showLoaderForSeconds(int seconds) {
    _loaderTimer?.cancel();
    _loaderTimer = null;

    if (seconds <= 0) {
      hideAdLoader();
      return;
    }

    _setAdLoaderVisible(true);
    _loaderTimer = Timer(Duration(seconds: seconds), hideAdLoader);
  }

  bool shouldShowShiftInterstitial({
    required AdConfigModel config,
    bool isExcludedButton = false,
  }) {
    if (isExcludedButton ||
        !config.isAdsMasterEnabled ||
        !config.shiftInterstitialEnabled) {
      return false;
    }

    _shiftInterstitialClickCount++;

    final clickCap = config.shiftInterstitialClickCap <= 0
        ? 1
        : config.shiftInterstitialClickCap;
    final hasReachedClickCap = _shiftInterstitialClickCount >= clickCap;
    final canShowByTimer = _hasShiftInterstitialTimerElapsed(
      config.shiftInterstitialTimerSeconds,
    );

    notifyListeners();
    return hasReachedClickCap && canShowByTimer;
  }

  void markShiftInterstitialShown() {
    _lastShiftInterstitialShownAt = DateTime.now();
    _shiftInterstitialClickCount = 0;
    notifyListeners();
  }

  void resetShiftInterstitialCapping() {
    _shiftInterstitialClickCount = 0;
    _lastShiftInterstitialShownAt = null;
    notifyListeners();
  }

  Future<void> loadSplashInterstitial(AdConfigModel config) async {
    if (_splashInterstitialAd != null || _isLoadingSplashInterstitial) {
      return;
    }

    _isLoadingSplashInterstitial = true;
    notifyListeners();

    try {
      _splashInterstitialAd = await _adService.loadInterstitialAd(
        adUnitId: config.splashInterstitialAdId,
        placementName: 'splash_interstitial',
      );
    } catch (error) {
      debugPrint('[AdViewModel] Splash interstitial load failed: $error');
      _splashInterstitialAd = null;
    } finally {
      _isLoadingSplashInterstitial = false;
      notifyListeners();
    }
  }

  Future<void> loadShiftInterstitial(AdConfigModel config) async {
    if (!config.isAdsMasterEnabled ||
        !config.shiftInterstitialEnabled ||
        _shiftInterstitialAd != null ||
        _isLoadingShiftInterstitial) {
      return;
    }

    _isLoadingShiftInterstitial = true;
    notifyListeners();

    try {
      _shiftInterstitialAd = await _adService.loadInterstitialAd(
        adUnitId: config.shiftInterstitialAdId,
        placementName: 'shift_interstitial',
      );
    } catch (error) {
      debugPrint('[AdViewModel] Shift interstitial load failed: $error');
      _shiftInterstitialAd = null;
    } finally {
      _isLoadingShiftInterstitial = false;
      notifyListeners();
    }
  }

  Future<void> loadRewardedInterstitialAfterPremium(
    AdConfigModel config,
  ) async {
    if (_rewardedInterstitialAfterPremiumAd != null ||
        _isLoadingRewardedInterstitialAfterPremium) {
      return;
    }

    _isLoadingRewardedInterstitialAfterPremium = true;
    notifyListeners();

    try {
      _rewardedInterstitialAfterPremiumAd = await _adService
          .loadRewardedInterstitialAd(
            adUnitId: config.rewardedInterstitialAfterPremiumAdId,
            placementName: 'rewarded_interstitial_after_premium',
          );
    } catch (error) {
      debugPrint(
        '[AdViewModel] Rewarded interstitial after premium load failed: $error',
      );
      _rewardedInterstitialAfterPremiumAd = null;
    } finally {
      _isLoadingRewardedInterstitialAfterPremium = false;
      notifyListeners();
    }
  }

  Future<void> loadAppOpenAd(AdConfigModel config) async {
    if (!config.isAdsMasterEnabled ||
        !config.appOpenEnabled ||
        _appOpenAd != null ||
        _isLoadingAppOpenAd) {
      return;
    }

    _isLoadingAppOpenAd = true;
    notifyListeners();

    try {
      _appOpenAd = await _adService.loadAppOpenAd(
        adUnitId: config.appOpenAdId,
        placementName: 'app_open',
      );
    } catch (error) {
      debugPrint('[AdViewModel] App open ad load failed: $error');
      _appOpenAd = null;
    } finally {
      _isLoadingAppOpenAd = false;
      notifyListeners();
    }
  }

  Future<void> showSplashInterstitial({
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
  }) async {
    await _showInterstitial(
      ad: _splashInterstitialAd,
      placementName: 'splash_interstitial',
      clearCachedAd: () => _splashInterstitialAd = null,
      onDismissed: onDismissed,
      onFailedToShow: onFailedToShow,
    );
  }

  Future<void> showShiftInterstitial({
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
  }) async {
    await _showInterstitial(
      ad: _shiftInterstitialAd,
      placementName: 'shift_interstitial',
      clearCachedAd: () => _shiftInterstitialAd = null,
      onDismissed: () {
        markShiftInterstitialShown();
        _safeVoidCallback(onDismissed, 'shift_interstitial', 'onDismissed');
      },
      onFailedToShow: onFailedToShow,
    );
  }

  Future<void> showRewardedInterstitialAfterPremium({
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
    void Function(RewardItem reward)? onUserEarnedReward,
  }) async {
    if (!_beginFullScreenShow(
      _rewardedInterstitialAfterPremiumAd,
      'rewarded_interstitial_after_premium',
      onFailedToShow,
    )) {
      return;
    }

    final ad = _rewardedInterstitialAfterPremiumAd;
    _rewardedInterstitialAfterPremiumAd = null;
    notifyListeners();

    await _adService.showRewardedInterstitialAd(
      ad: ad,
      placementName: 'rewarded_interstitial_after_premium',
      onDismissed: () {
        _endFullScreenShow();
        _safeVoidCallback(
          onDismissed,
          'rewarded_interstitial_after_premium',
          'onDismissed',
        );
      },
      onFailedToShow: () {
        _endFullScreenShow();
        _safeVoidCallback(
          onFailedToShow,
          'rewarded_interstitial_after_premium',
          'onFailedToShow',
        );
      },
      onUserEarnedReward: onUserEarnedReward,
    );
  }

  Future<void> showAppOpenAd({
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
  }) async {
    if (!_beginFullScreenShow(_appOpenAd, 'app_open', onFailedToShow)) {
      return;
    }

    final ad = _appOpenAd;
    _appOpenAd = null;
    notifyListeners();

    await _adService.showAppOpenAd(
      ad: ad,
      placementName: 'app_open',
      onDismissed: () {
        _endFullScreenShow();
        _safeVoidCallback(onDismissed, 'app_open', 'onDismissed');
      },
      onFailedToShow: () {
        _endFullScreenShow();
        _safeVoidCallback(onFailedToShow, 'app_open', 'onFailedToShow');
      },
    );
  }

  @override
  void dispose() {
    _loaderTimer?.cancel();
    _adService.disposeInterstitialAd(
      _splashInterstitialAd,
      placementName: 'splash_interstitial',
    );
    _adService.disposeInterstitialAd(
      _shiftInterstitialAd,
      placementName: 'shift_interstitial',
    );
    _adService.disposeRewardedInterstitialAd(
      _rewardedInterstitialAfterPremiumAd,
      placementName: 'rewarded_interstitial_after_premium',
    );
    _adService.disposeAppOpenAd(_appOpenAd, placementName: 'app_open');
    super.dispose();
  }

  Future<void> _showInterstitial({
    required InterstitialAd? ad,
    required String placementName,
    required VoidCallback clearCachedAd,
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
  }) async {
    if (!_beginFullScreenShow(ad, placementName, onFailedToShow)) {
      return;
    }

    clearCachedAd();
    notifyListeners();

    await _adService.showInterstitialAd(
      ad: ad,
      placementName: placementName,
      onDismissed: () {
        _endFullScreenShow();
        _safeVoidCallback(onDismissed, placementName, 'onDismissed');
      },
      onFailedToShow: () {
        _endFullScreenShow();
        _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
      },
    );
  }

  bool _beginFullScreenShow(
    Object? ad,
    String placementName,
    VoidCallback? onFailedToShow,
  ) {
    if (_isFullScreenAdShowing) {
      debugPrint(
        '[AdViewModel][$placementName] Full-screen ad already showing.',
      );
      _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
      return false;
    }

    if (ad == null) {
      debugPrint('[AdViewModel][$placementName] Cached ad is null.');
      _safeVoidCallback(onFailedToShow, placementName, 'onFailedToShow');
      return false;
    }

    _isFullScreenAdShowing = true;
    notifyListeners();
    return true;
  }

  void _endFullScreenShow() {
    if (!_isFullScreenAdShowing) {
      return;
    }

    _isFullScreenAdShowing = false;
    notifyListeners();
  }

  bool _hasShiftInterstitialTimerElapsed(int timerSeconds) {
    final lastShownAt = _lastShiftInterstitialShownAt;

    if (lastShownAt == null) {
      return true;
    }

    final effectiveTimerSeconds = timerSeconds <= 0 ? 0 : timerSeconds;
    final elapsedSeconds = DateTime.now().difference(lastShownAt).inSeconds;
    return elapsedSeconds >= effectiveTimerSeconds;
  }

  void _setAdLoaderVisible(bool visible) {
    if (_isAdLoaderVisible == visible) {
      return;
    }

    _isAdLoaderVisible = visible;
    notifyListeners();
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
        '[AdViewModel][$placementName] Callback $callbackName failed: $error',
      );
    }
  }
}
