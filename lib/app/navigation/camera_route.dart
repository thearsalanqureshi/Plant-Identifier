import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CameraRoute {
  const CameraRoute._();

  static Route<T> blackFade<T>({
    required String routeName,
    required Widget child,
    Object? arguments,
    Duration transitionDuration = const Duration(milliseconds: 240),
    Duration reverseTransitionDuration = const Duration(milliseconds: 180),
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(
        name: routeName,
        arguments: arguments,
      ),
      opaque: true,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ColoredBox(
          color: AppColors.black,
          child: child,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.black),
            FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ],
        );
      },
    );
  }
}
