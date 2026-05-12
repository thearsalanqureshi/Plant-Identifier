import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

@immutable
class ScannerPreviewPayload {
  const ScannerPreviewPayload({
    required this.sourceFile,
    required this.thumbnailImage,
    required this.mode,
  });

  final File sourceFile;
  final ui.Image thumbnailImage;
  final String mode;

  void dispose() {
    thumbnailImage.dispose();
  }
}

Future<ScannerPreviewPayload?> prepareScannerPreviewPayload({
  required File sourceFile,
  required String mode,
  required ui.Size previewSize,
  required double devicePixelRatio,
}) async {
  if (!await sourceFile.exists()) {
    return null;
  }

  final bytes = await sourceFile.readAsBytes();
  final targetWidth = _decodeTargetDimension(
    previewSize.width,
    devicePixelRatio,
  );
  final targetHeight = _decodeTargetDimension(
    previewSize.height,
    devicePixelRatio,
  );
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: targetWidth,
    targetHeight: targetHeight,
  );
  final frame = await codec.getNextFrame();
  codec.dispose();

  return ScannerPreviewPayload(
    sourceFile: sourceFile,
    thumbnailImage: frame.image,
    mode: mode,
  );
}

int _decodeTargetDimension(double logicalSize, double devicePixelRatio) {
  final physicalSize = (logicalSize * devicePixelRatio).round();
  if (physicalSize < 1) {
    return 1;
  }

  return physicalSize.clamp(1, 1600).toInt();
}
