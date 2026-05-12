enum ScannerAspectRatio {
  ratio3x4,
  ratio1x1,
  ratio9x16,
  full,
}

extension ScannerAspectRatioX on ScannerAspectRatio {
  String get label {
    switch (this) {
      case ScannerAspectRatio.ratio3x4:
        return '3:4';
      case ScannerAspectRatio.ratio1x1:
        return '1:1';
      case ScannerAspectRatio.ratio9x16:
        return '9:16';
      case ScannerAspectRatio.full:
        return 'Full';
    }
  }

  double? get value {
    switch (this) {
      case ScannerAspectRatio.ratio3x4:
        return 3 / 4;
      case ScannerAspectRatio.ratio1x1:
        return 1;
      case ScannerAspectRatio.ratio9x16:
        return 9 / 16;
      case ScannerAspectRatio.full:
        return null;
    }
  }
}

enum ScannerOverlayMode {
  off,
  grid,
  focus,
}

extension ScannerOverlayModeX on ScannerOverlayMode {
  bool get isActive => this != ScannerOverlayMode.off;
}

enum ScannerCaptureTimerOption {
  off,
  threeSeconds,
  fiveSeconds,
  tenSeconds,
}

extension ScannerCaptureTimerOptionX on ScannerCaptureTimerOption {
  int? get seconds {
    switch (this) {
      case ScannerCaptureTimerOption.off:
        return null;
      case ScannerCaptureTimerOption.threeSeconds:
        return 3;
      case ScannerCaptureTimerOption.fiveSeconds:
        return 5;
      case ScannerCaptureTimerOption.tenSeconds:
        return 10;
    }
  }

  String get label {
    switch (this) {
      case ScannerCaptureTimerOption.off:
        return 'Off';
      case ScannerCaptureTimerOption.threeSeconds:
        return '3s';
      case ScannerCaptureTimerOption.fiveSeconds:
        return '5s';
      case ScannerCaptureTimerOption.tenSeconds:
        return '10s';
    }
  }
}
