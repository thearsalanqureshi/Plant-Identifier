import 'package:flutter/foundation.dart';

import '../data/models/ad_config_model.dart';
import '../data/services/remote_config_service.dart';

class AdConfigViewModel extends ChangeNotifier {
  final RemoteConfigService _remoteConfigService;

  AdConfigModel _config = AdConfigModel.defaults();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  Future<void>? _initializeFuture;

  AdConfigViewModel({RemoteConfigService? remoteConfigService})
    : _remoteConfigService = remoteConfigService ?? RemoteConfigService();

  AdConfigModel get config => _config;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() {
    if (_isInitialized) {
      return Future.value();
    }

    final runningInitialization = _initializeFuture;
    if (runningInitialization != null) {
      return runningInitialization;
    }

    _initializeFuture = _loadConfig();
    return _initializeFuture!;
  }

  Future<void> _loadConfig() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _config = await _remoteConfigService.fetchAdConfig();
      _errorMessage = _remoteConfigService.lastErrorMessage;
    } catch (error) {
      _config = AdConfigModel.defaults();
      _errorMessage = 'Ad config initialization failed: $error';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      _isInitialized = true;
      _initializeFuture = null;
      notifyListeners();
    }
  }
}
