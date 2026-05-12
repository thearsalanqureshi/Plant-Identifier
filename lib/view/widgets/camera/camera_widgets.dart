import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/scanner_camera_options.dart';

class CameraPreviewHost extends StatelessWidget {
  const CameraPreviewHost({
    super.key,
    required this.controller,
    this.backgroundColor = Colors.black,
    this.placeholder,
    this.fit = BoxFit.cover,
    this.isReady = true,
  });

  final CameraController? controller;
  final Color backgroundColor;
  final Widget? placeholder;
  final BoxFit fit;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = controller;

    if (cameraController == null ||
        !cameraController.value.isInitialized ||
        !isReady) {
      return placeholder ?? ColoredBox(color: backgroundColor);
    }

    final previewSize = cameraController.value.previewSize;
    if (previewSize == null) {
      return placeholder ?? ColoredBox(color: backgroundColor);
    }

    return ColoredBox(
      color: backgroundColor,
      child: SizedBox.expand(
        child: ClipRect(
          child: FittedBox(
            fit: fit,
            alignment: Alignment.center,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(cameraController),
            ),
          ),
        ),
      ),
    );
  }
}

class CameraTopGlyphButton extends StatelessWidget {
  const CameraTopGlyphButton({
    super.key,
    required this.child,
    required this.onTap,
    this.size = 44,
    this.selected = false,
    this.selectedColor = AppColors.cameraAccent,
    this.unselectedColor = Colors.white,
  });

  final Widget child;
  final VoidCallback onTap;
  final double size;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = selected ? selectedColor : unselectedColor;

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: size / 2,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foregroundColor),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CameraBracketFrame extends StatelessWidget {
  const CameraBracketFrame({
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.strokeWidth = 2.2,
    this.cornerRadiusFactor = 0.28,
    this.cornerLengthFactor = 0.36,
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final double cornerRadiusFactor;
  final double cornerLengthFactor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BracketFramePainter(
          color: color,
          strokeWidth: strokeWidth,
          cornerRadiusFactor: cornerRadiusFactor,
          cornerLengthFactor: cornerLengthFactor,
        ),
      ),
    );
  }
}

class CameraAspectRatioCompactBadge extends StatelessWidget {
  const CameraAspectRatioCompactBadge({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color accent = selected ? AppColors.cameraAccent : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 36, minHeight: 28),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CameraBracketFrame(
                    size: 20,
                    color: accent,
                    strokeWidth: 1.8,
                    cornerRadiusFactor: 0.24,
                    cornerLengthFactor: 0.30,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: accent,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CameraContextualOptionPill extends StatelessWidget {
  const CameraContextualOptionPill({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color accent = selected ? AppColors.cameraAccent : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.56),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accent,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _BracketFramePainter extends CustomPainter {
  const _BracketFramePainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerRadiusFactor,
    required this.cornerLengthFactor,
  });

  final Color color;
  final double strokeWidth;
  final double cornerRadiusFactor;
  final double cornerLengthFactor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final double inset = strokeWidth / 2;
    final double shortestSide = math.min(size.width, size.height);
    final double cornerLength =
        math.max(4.0, shortestSide * cornerLengthFactor - strokeWidth);
    final double cornerRadius =
        math.max(2.0, shortestSide * cornerRadiusFactor - strokeWidth);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;

    Path cornerPath(Offset start, Offset middle, Offset end) {
      return Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(middle.dx, middle.dy)
        ..lineTo(end.dx, end.dy);
    }

    canvas.drawPath(
      cornerPath(
        Offset(left + cornerRadius, top),
        Offset(left, top),
        Offset(left, top + cornerLength),
      ),
      paint,
    );

    canvas.drawPath(
      cornerPath(
        Offset(right - cornerRadius, top),
        Offset(right, top),
        Offset(right, top + cornerLength),
      ),
      paint,
    );

    canvas.drawPath(
      cornerPath(
        Offset(left, bottom - cornerLength),
        Offset(left, bottom),
        Offset(left + cornerRadius, bottom),
      ),
      paint,
    );

    canvas.drawPath(
      cornerPath(
        Offset(right, bottom - cornerLength),
        Offset(right, bottom),
        Offset(right - cornerRadius, bottom),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BracketFramePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerRadiusFactor != cornerRadiusFactor ||
        oldDelegate.cornerLengthFactor != cornerLengthFactor;
  }
}

class CameraToggleChip extends StatelessWidget {
  const CameraToggleChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        selected ? const Color(0xFF589C68) : const Color(0x801E1F24);
    final Color foregroundColor = selected ? Colors.white : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? Colors.white : Colors.white24,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foregroundColor, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraAspectRatioSelector extends StatelessWidget {
  const CameraAspectRatioSelector({
    super.key,
    required this.selectedAspectRatio,
    required this.onChanged,
  });

  final ScannerAspectRatio selectedAspectRatio;
  final ValueChanged<ScannerAspectRatio> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        CameraToggleChip(
          label: ScannerAspectRatio.ratio3x4.label,
          selected: selectedAspectRatio == ScannerAspectRatio.ratio3x4,
          onTap: () => onChanged(ScannerAspectRatio.ratio3x4),
        ),
        CameraToggleChip(
          label: ScannerAspectRatio.ratio1x1.label,
          selected: selectedAspectRatio == ScannerAspectRatio.ratio1x1,
          onTap: () => onChanged(ScannerAspectRatio.ratio1x1),
        ),
        CameraToggleChip(
          label: ScannerAspectRatio.ratio9x16.label,
          selected: selectedAspectRatio == ScannerAspectRatio.ratio9x16,
          onTap: () => onChanged(ScannerAspectRatio.ratio9x16),
        ),
        CameraToggleChip(
          label: ScannerAspectRatio.full.label,
          selected: selectedAspectRatio == ScannerAspectRatio.full,
          onTap: () => onChanged(ScannerAspectRatio.full),
        ),
      ],
    );
  }
}

class CameraTimerSelector extends StatelessWidget {
  const CameraTimerSelector({
    super.key,
    required this.selectedTimer,
    required this.onChanged,
  });

  final ScannerCaptureTimerOption selectedTimer;
  final ValueChanged<ScannerCaptureTimerOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        CameraToggleChip(
          label: 'Off',
          icon: Icons.timer_off,
          selected: selectedTimer == ScannerCaptureTimerOption.off,
          onTap: () => onChanged(ScannerCaptureTimerOption.off),
        ),
        CameraToggleChip(
          label: '3s',
          icon: Icons.schedule,
          selected: selectedTimer == ScannerCaptureTimerOption.threeSeconds,
          onTap: () => onChanged(ScannerCaptureTimerOption.threeSeconds),
        ),
        CameraToggleChip(
          label: '5s',
          icon: Icons.schedule,
          selected: selectedTimer == ScannerCaptureTimerOption.fiveSeconds,
          onTap: () => onChanged(ScannerCaptureTimerOption.fiveSeconds),
        ),
      ],
    );
  }
}

class CameraRuleOfThirdsGridOverlay extends StatelessWidget {
  const CameraRuleOfThirdsGridOverlay({super.key, this.lineColor});

  final Color? lineColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _RuleOfThirdsGridPainter(
          lineColor: lineColor ?? Colors.white.withOpacity(0.25),
        ),
      ),
    );
  }
}

class _RuleOfThirdsGridPainter extends CustomPainter {
  const _RuleOfThirdsGridPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    canvas.drawLine(
      Offset(thirdWidth, 0),
      Offset(thirdWidth, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(thirdWidth * 2, 0),
      Offset(thirdWidth * 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, thirdHeight),
      Offset(size.width, thirdHeight),
      paint,
    );
    canvas.drawLine(
      Offset(0, thirdHeight * 2),
      Offset(size.width, thirdHeight * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RuleOfThirdsGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

class CameraAspectRatioFrameOverlay extends StatelessWidget {
  const CameraAspectRatioFrameOverlay({
    super.key,
    required this.aspectRatio,
    this.frameColor,
    this.maskColor,
  });

  final ScannerAspectRatio aspectRatio;
  final Color? frameColor;
  final Color? maskColor;

  @override
  Widget build(BuildContext context) {
    final ratio = aspectRatio.value;
    if (ratio == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: _AspectRatioFramePainter(
          aspectRatio: ratio,
          frameColor: frameColor ?? Colors.white.withOpacity(0.4),
          maskColor: maskColor ?? Colors.black.withOpacity(0.18),
        ),
      ),
    );
  }
}

class _AspectRatioFramePainter extends CustomPainter {
  const _AspectRatioFramePainter({
    required this.aspectRatio,
    required this.frameColor,
    required this.maskColor,
  });

  final double aspectRatio;
  final Color frameColor;
  final Color maskColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final frameWidth = math.min(size.width, size.height * aspectRatio);
    final frameHeight = frameWidth / aspectRatio;
    final frameRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: frameWidth,
      height: frameHeight,
    );

    final maskPaint = Paint()..color = maskColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, frameRect.top), maskPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, frameRect.bottom, size.width, size.height - frameRect.bottom),
      maskPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, frameRect.top, frameRect.left, frameRect.height),
      maskPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        frameRect.right,
        frameRect.top,
        size.width - frameRect.right,
        frameRect.height,
      ),
      maskPaint,
    );

    final borderPaint = Paint()
      ..color = frameColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(frameRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AspectRatioFramePainter oldDelegate) {
    return oldDelegate.aspectRatio != aspectRatio ||
        oldDelegate.frameColor != frameColor ||
        oldDelegate.maskColor != maskColor;
  }
}

class CameraFocusReticleOverlay extends StatelessWidget {
  const CameraFocusReticleOverlay({
    super.key,
    required this.normalizedPosition,
    this.size = 72,
    this.color = Colors.white,
    this.strokeWidth = 2.4,
  });

  final Offset normalizedPosition;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final center = Offset(
            normalizedPosition.dx.clamp(0.0, 1.0).toDouble() * width,
            normalizedPosition.dy.clamp(0.0, 1.0).toDouble() * height,
          );
          final left = (center.dx - size / 2)
              .clamp(0.0, math.max(0.0, width - size))
              .toDouble();
          final top = (center.dy - size / 2)
              .clamp(0.0, math.max(0.0, height - size))
              .toDouble();

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.85, end: 1.0),
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 240),
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: CameraBracketFrame(
                      size: size,
                      color: color,
                      strokeWidth: strokeWidth,
                      cornerRadiusFactor: 0.24,
                      cornerLengthFactor: 0.34,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CameraCountdownOverlay extends StatelessWidget {
  const CameraCountdownOverlay({
    super.key,
    required this.remainingSeconds,
  });

  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.black.withOpacity(0.24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$remainingSeconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 78,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Capturing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraRoundActionButton extends StatelessWidget {
  const CameraRoundActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 22,
    this.backgroundColor = const Color(0x801E1F24),
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}

class CameraCaptureButton extends StatelessWidget {
  const CameraCaptureButton({
    super.key,
    required this.onTap,
    this.enabled = true,
    this.size = 72,
    this.fillColor = const Color(0xFF589C68),
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.iconSize = 30,
  });

  final VoidCallback onTap;
  final bool enabled;
  final double size;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(size / 2),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.55,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
