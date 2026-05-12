class AdConfigModel {
  final bool isAdsMasterEnabled;
  final String nativeCtaColor;
  final String nativeTextColor;
  final bool appOpenEnabled;
  final String appOpenAdId;
  final bool onboardingNativeEnabled;
  final String onboardingNativeAdId;
  final String onboardingNativeVariant;
  final bool bannerEnabled;
  final String bannerAdId;
  final String bannerType;
  final bool homeNative1Enabled;
  final String homeNative1AdId;
  final String homeNative1Variant;
  final bool homeNative2Enabled;
  final String homeNative2AdId;
  final String homeNative2Variant;
  final bool shiftInterstitialEnabled;
  final String shiftInterstitialAdId;
  final int shiftInterstitialClickCap;
  final int shiftInterstitialTimerSeconds;
  final int loaderTimerSeconds;
  final String nativeVariantDefault;
  final String splashInterstitialAdId;
  final String rewardedInterstitialAfterPremiumAdId;

  const AdConfigModel({
    required this.isAdsMasterEnabled,
    required this.nativeCtaColor,
    required this.nativeTextColor,
    required this.appOpenEnabled,
    required this.appOpenAdId,
    required this.onboardingNativeEnabled,
    required this.onboardingNativeAdId,
    required this.onboardingNativeVariant,
    required this.bannerEnabled,
    required this.bannerAdId,
    required this.bannerType,
    required this.homeNative1Enabled,
    required this.homeNative1AdId,
    required this.homeNative1Variant,
    required this.homeNative2Enabled,
    required this.homeNative2AdId,
    required this.homeNative2Variant,
    required this.shiftInterstitialEnabled,
    required this.shiftInterstitialAdId,
    required this.shiftInterstitialClickCap,
    required this.shiftInterstitialTimerSeconds,
    required this.loaderTimerSeconds,
    required this.nativeVariantDefault,
    required this.splashInterstitialAdId,
    required this.rewardedInterstitialAfterPremiumAdId,
  });

  factory AdConfigModel.defaults() {
    return const AdConfigModel(
      isAdsMasterEnabled: true,
      nativeCtaColor: '#00ACC4',
      nativeTextColor: '#333333',
      appOpenEnabled: true,
      appOpenAdId: 'ca-app-pub-3940256099942544/9257395921',
      onboardingNativeEnabled: true,
      onboardingNativeAdId: 'ca-app-pub-3940256099942544/2247696110',
      onboardingNativeVariant: 'full_screen',
      bannerEnabled: true,
      bannerAdId: 'ca-app-pub-3940256099942544/6300978111',
      bannerType: 'adaptive',
      homeNative1Enabled: true,
      homeNative1AdId: 'ca-app-pub-3940256099942544/2247696110',
      homeNative1Variant: '6b',
      homeNative2Enabled: true,
      homeNative2AdId: 'ca-app-pub-3940256099942544/2247696110',
      homeNative2Variant: '7b',
      shiftInterstitialEnabled: true,
      shiftInterstitialAdId: 'ca-app-pub-3940256099942544/1033173712',
      shiftInterstitialClickCap: 3,
      shiftInterstitialTimerSeconds: 60,
      loaderTimerSeconds: 2,
      nativeVariantDefault: '6b',
      splashInterstitialAdId: 'ca-app-pub-3940256099942544/1033173712',
      rewardedInterstitialAfterPremiumAdId:
          'ca-app-pub-3940256099942544/5354046379',
    );
  }

  factory AdConfigModel.fromJson(Map<String, dynamic> json) {
    final defaults = AdConfigModel.defaults();

    return AdConfigModel(
      isAdsMasterEnabled: _readBool(
        json,
        'is_ads_master_enabled',
        defaults.isAdsMasterEnabled,
      ),
      nativeCtaColor: _readHexColorString(
        json,
        'native_cta_color',
        defaults.nativeCtaColor,
      ),
      nativeTextColor: _readHexColorString(
        json,
        'native_text_color',
        defaults.nativeTextColor,
      ),
      appOpenEnabled: _readBool(
        json,
        'app_open_enabled',
        defaults.appOpenEnabled,
      ),
      appOpenAdId: _readString(json, 'app_open_ad_id', defaults.appOpenAdId),
      onboardingNativeEnabled: _readBool(
        json,
        'onboarding_native_enabled',
        defaults.onboardingNativeEnabled,
      ),
      onboardingNativeAdId: _readString(
        json,
        'onboarding_native_ad_id',
        defaults.onboardingNativeAdId,
      ),
      onboardingNativeVariant: _readString(
        json,
        'onboarding_native_variant',
        defaults.onboardingNativeVariant,
      ),
      bannerEnabled: _readBool(json, 'banner_enabled', defaults.bannerEnabled),
      bannerAdId: _readString(json, 'banner_ad_id', defaults.bannerAdId),
      bannerType: _readBannerType(json, defaults.bannerType),
      homeNative1Enabled: _readBool(
        json,
        'home_native_1_enabled',
        defaults.homeNative1Enabled,
      ),
      homeNative1AdId: _readString(
        json,
        'home_native_1_ad_id',
        defaults.homeNative1AdId,
      ),
      homeNative1Variant: _readString(
        json,
        'home_native_1_variant',
        defaults.homeNative1Variant,
      ),
      homeNative2Enabled: _readBool(
        json,
        'home_native_2_enabled',
        defaults.homeNative2Enabled,
      ),
      homeNative2AdId: _readString(
        json,
        'home_native_2_ad_id',
        defaults.homeNative2AdId,
      ),
      homeNative2Variant: _readString(
        json,
        'home_native_2_variant',
        defaults.homeNative2Variant,
      ),
      shiftInterstitialEnabled: _readBool(
        json,
        'shift_interstitial_enabled',
        defaults.shiftInterstitialEnabled,
      ),
      shiftInterstitialAdId: _readString(
        json,
        'shift_interstitial_ad_id',
        defaults.shiftInterstitialAdId,
      ),
      shiftInterstitialClickCap: _readInt(
        json,
        'shift_interstitial_click_cap',
        defaults.shiftInterstitialClickCap,
      ),
      shiftInterstitialTimerSeconds: _readInt(
        json,
        'shift_interstitial_timer_seconds',
        defaults.shiftInterstitialTimerSeconds,
      ),
      loaderTimerSeconds: _readInt(
        json,
        'loader_timer_seconds',
        defaults.loaderTimerSeconds,
      ),
      nativeVariantDefault: _readString(
        json,
        'native_variant_default',
        defaults.nativeVariantDefault,
      ),
      splashInterstitialAdId: defaults.splashInterstitialAdId,
      rewardedInterstitialAfterPremiumAdId:
          defaults.rewardedInterstitialAfterPremiumAdId,
    );
  }

  static bool _readBool(Map<String, dynamic> json, String key, bool fallback) {
    final value = json[key];

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
          return true;
        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }

    return fallback;
  }

  static int _readInt(Map<String, dynamic> json, String key, int fallback) {
    final value = json[key];

    if (value is int) {
      return value;
    }

    if (value is num && value.isFinite) {
      return value.round();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }

    return fallback;
  }

  static String _readString(
    Map<String, dynamic> json,
    String key,
    String fallback,
  ) {
    final value = json[key];

    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }

    return fallback;
  }

  static String _readBannerType(Map<String, dynamic> json, String fallback) {
    final value = _readString(json, 'banner_type', fallback).toLowerCase();

    if (value == 'adaptive' || value == 'collapsible') {
      return value;
    }

    return fallback;
  }

  static String _readHexColorString(
    Map<String, dynamic> json,
    String key,
    String fallback,
  ) {
    final value = _readString(json, key, fallback);
    return _isSimpleHexColor(value) ? value : fallback;
  }

  static bool _isSimpleHexColor(String value) {
    return RegExp(r'^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(value);
  }
}
