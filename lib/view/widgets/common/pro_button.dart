import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/constants.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class ProButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const ProButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.2 * 3.1415926535897932 / 180, // -0.2 degrees in radians
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFB300), 
                Color(0xFFFFD54F), 
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppConstants.premiumIcon,
                width: 16,
                height: 14,
                color: AppColors.black,
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.pro,
                style: AppTypography.proButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}