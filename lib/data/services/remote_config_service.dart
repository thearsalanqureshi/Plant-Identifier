import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../models/ad_config_model.dart';

class RemoteConfigService {
  static const String adsConfigAndroidKey = 'ads_config_android';

  static const Map<String, dynamic> _defaultAdsConfigAndroid = {
    'is_ads_master_enabled': true,
    'native_cta_color': '#00ACC4',
    'native_text_color': '#333333',
    'app_open_enabled': true,
    'app_open_ad_id': 'ca-app-pub-3940256099942544/9257395921',
    'onboarding_native_enabled': true,
    'onboarding_native_ad_id': 'ca-app-pub-3940256099942544/2247696110',
    'onboarding_native_variant': 'full_screen',
    'banner_enabled': true,
    'banner_ad_id': 'ca-app-pub-3940256099942544/6300978111',
    'banner_type': 'adaptive',
    'home_native_1_enabled': true,
    'home_native_1_ad_id': 'ca-app-pub-3940256099942544/2247696110',
    'home_native_1_variant': '6b',
    'home_native_2_enabled': true,
    'home_native_2_ad_id': 'ca-app-pub-3940256099942544/2247696110',
    'home_native_2_variant': '7b',
    'shift_interstitial_enabled': true,
    'shift_interstitial_ad_id': 'ca-app-pub-3940256099942544/1033173712',
    'shift_interstitial_click_cap': 3,
    'shift_interstitial_timer_seconds': 60,
    'loader_timer_seconds': 2,
    'native_variant_default': '6b',
  };

  final FirebaseRemoteConfig _remoteConfig;
  String? _lastErrorMessage;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  String? get lastErrorMessage => _lastErrorMessage;

  static String get defaultAdsConfigAndroidJson {
    return jsonEncode(_defaultAdsConfigAndroid);
  }

  Future<AdConfigModel> fetchAdConfig() async {
    _lastErrorMessage = null;

    try {
      await _remoteConfig.setDefaults({
        adsConfigAndroidKey: defaultAdsConfigAndroidJson,
      });

      try {
        await _remoteConfig.fetchAndActivate();
      } catch (error) {
        _lastErrorMessage = 'Remote Config fetch failed: $error';
        debugPrint(_lastErrorMessage);
      }

      final rawConfig = _remoteConfig.getString(adsConfigAndroidKey);
      return _parseAdsConfig(rawConfig);
    } catch (error) {
      _lastErrorMessage = 'Remote Config setup failed: $error';
      debugPrint(_lastErrorMessage);
      return AdConfigModel.defaults();
    }
  }

  AdConfigModel _parseAdsConfig(String rawConfig) {
    try {
      final trimmedConfig = rawConfig.trim();

      if (trimmedConfig.isEmpty) {
        _lastErrorMessage = 'Remote Config ads_config_android is empty.';
        debugPrint(_lastErrorMessage);
        return AdConfigModel.defaults();
      }

      final decoded = jsonDecode(trimmedConfig);

      if (decoded is Map<String, dynamic>) {
        return AdConfigModel.fromJson(decoded);
      }

      if (decoded is Map) {
        final safeMap = decoded.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );
        return AdConfigModel.fromJson(safeMap);
      }

      _lastErrorMessage =
          'Remote Config ads_config_android must be a JSON object.';
      debugPrint(_lastErrorMessage);
      return AdConfigModel.defaults();
    } catch (error) {
      _lastErrorMessage = 'Remote Config JSON parse failed: $error';
      debugPrint(_lastErrorMessage);
      return AdConfigModel.defaults();
    }
  }
}
