import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final String semanticsLabel;

  const AppLogo({
    super.key,
    this.size = 96,
    this.semanticsLabel = 'App logo',
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppConstants.appLogoSvg,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: semanticsLabel,
    );
  }
}
