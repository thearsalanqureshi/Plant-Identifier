import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ad_design_tokens.dart';

class AdLoaderWidget extends StatelessWidget {
  final double baseWidth;
  final double baseHeight;

  const AdLoaderWidget({super.key, this.baseWidth = 127, this.baseHeight = 42});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : baseWidth;
        final actualWidth = math.min(parentWidth, baseWidth);
        final scale = actualWidth / baseWidth;

        return Center(
          child: SizedBox(
            width: actualWidth,
            height: baseHeight * scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AdDesignTokens.white,
                borderRadius: BorderRadius.circular(
                  AdDesignTokens.scaledSize(10, scale, min: 8),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AdDesignTokens.shadow,
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AdDesignTokens.scaledSize(12, scale, min: 10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: AdDesignTokens.scaledSize(18, scale, min: 16),
                      height: AdDesignTokens.scaledSize(18, scale, min: 16),
                      child: _GradientSpinner(scale: scale),
                    ),
                    SizedBox(
                      width: AdDesignTokens.scaledSize(8, scale, min: 6),
                    ),
                    Expanded(
                      child: Text(
                        'Showing Ad',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AdDesignTokens.mainText,
                          fontFamily: AdDesignTokens.fontFamily,
                          fontSize: AdDesignTokens.scaledFont(
                            12,
                            scale,
                            min: 11,
                          ),
                          fontWeight: FontWeight.w600,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GradientSpinner extends StatelessWidget {
  final double scale;

  const _GradientSpinner({required this.scale});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientSpinnerPainter(
        strokeWidth: AdDesignTokens.scaledSize(2.2, scale, min: 1.8),
      ),
    );
  }
}

class _GradientSpinnerPainter extends CustomPainter {
  final double strokeWidth;

  const _GradientSpinnerPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);
    final gradient = SweepGradient(
      colors: const [
        AdDesignTokens.loaderStart,
        AdDesignTokens.loaderEnd,
        AdDesignTokens.loaderStart,
      ],
      transform: GradientRotation(133.96 * math.pi / 180),
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 1.55, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientSpinnerPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth;
  }
}
