import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../utils/app_types.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final CardSize size;
  final CardType type;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _CardConfig.getConfig(type);
    final isLarge = size == CardSize.large;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    final cardHeight = isLarge
        ? (isTablet ? 136.0 : 100.0)
        : (isTablet ? 220.0 : 165.0);

    final iconSize = isLarge
        ? (isTablet ? 34.0 : 28.0)
        : (isTablet ? 40.0 : 36.0);

    final bgSize = isLarge
        ? (isTablet ? 170.0 : 148.0)
        : (isTablet ? 185.0 : 155.0);

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (config.backgroundImage != null)
                  Positioned(
                    bottom: isLarge ? -20 : -14,
                    right: isRtl ? null : (isLarge ? -4 : -2),
                    left: isRtl ? (isLarge ? -4 : -2) : null,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(isRtl ? -1.0 : 1.0, 1.0),
                      child: Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          config.backgroundImage!,
                          width: bgSize,
                          height: bgSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    left: isRtl ? 0 : (isLarge ? (isTablet ? 22 : 19) : 11),
                    right: isRtl ? (isLarge ? (isTablet ? 22 : 19) : 11) : 0,
                    top: isLarge ? (isTablet ? 18 : 16) : (isTablet ? 20 : 18),
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        config.mainIcon,
                        width: iconSize,
                        height: iconSize,
                        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                      ),
                      SizedBox(height: isLarge ? (isTablet ? 18 : 8) : (isTablet ? 62 : 44)),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: (isLarge ? AppTypography.featureCardTitle : AppTypography.smallCardTitle).copyWith(
                          fontSize: isTablet ? 26 : 18,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: (isLarge ? AppTypography.featureCardSubtitle : AppTypography.smallCardSubtitle).copyWith(
                          fontSize: isTablet ? 20 : (isLarge ? 14 : 13),
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });

  static _CardConfig getConfig(CardType type) {
    final baseConfig = _BaseCardConfigs.getBaseConfig(type);
    return _CardConfig(
      backgroundColor: baseConfig.backgroundColor,
      mainIcon: baseConfig.mainIcon,
      backgroundImage: baseConfig.backgroundImage,
    );
  }
}

class _BaseCardConfigs {
  static final Map<CardType, _CardBaseConfig> _configs = {
    CardType.identify: _CardBaseConfig(
      backgroundColor: AppColors.identifyCard,
      mainIcon: 'assets/icons/ic_identify.svg',
      backgroundImage: 'assets/images/bg_identify.png',
    ),
    CardType.diagnose: _CardBaseConfig(
      backgroundColor: AppColors.diagnoseCard,
      mainIcon: 'assets/icons/ic_diagnose.svg',
      backgroundImage: 'assets/images/bg_diagnose.png',
    ),
    CardType.water: _CardBaseConfig(
      backgroundColor: AppColors.waterCalculatorCard,
      mainIcon: 'assets/icons/ic_water_calc.svg',
      backgroundImage: 'assets/images/bg_water_calc.png',
    ),
    CardType.light: _CardBaseConfig(
      backgroundColor: AppColors.lightMeterCard,
      mainIcon: 'assets/icons/ic_light_meter.svg',
      backgroundImage: 'assets/images/bg_light_meter.png',
    ),
  };

  static _CardBaseConfig getBaseConfig(CardType type) {
    return _configs[type] ?? _configs[CardType.identify]!;
  }
}

class _CardBaseConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardBaseConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });
}



// Before Refactoring 12/03/26 - 05:00pm
/*import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../utils/app_types.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final CardSize size;
  final CardType type;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _CardConfig.getConfig(type);
    final isLarge = size == CardSize.large;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final cardHeight = isLarge
        ? (isTablet ? 120.0 : 100.0)
        : (isTablet ? 190.0 : 165.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: cardHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: config.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (config.backgroundImage != null)
                Positioned(
                  bottom: isLarge ? -20 : -14,
                  right: isRtl ? null : (isLarge ? -4 : -2),
                  left: isRtl ? (isLarge ? -4 : -2) : null,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(isRtl ? -1.0 : 1.0, 1.0),
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        config.backgroundImage!,
                        width: isLarge ? 148 : 155,
                        height: isLarge ? 148 : 155,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(
                  left: isRtl ? 0 : (isLarge ? 19.0 : 11.0),
                  right: isRtl ? (isLarge ? 19.0 : 11.0) : 0,
                  top: isLarge ? 16 : 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            config.mainIcon,
                            width: isLarge ? 28 : 36,
                            height: isLarge ? 28 : 36,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(height: isLarge ? 8 : (isTablet ? 52 : 44)),
                          Text(
                            title,
                            style: (isLarge
                                    ? AppTypography.featureCardTitle
                                    : AppTypography.smallCardTitle)
                                .copyWith(fontSize: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: (isLarge
                                    ? AppTypography.featureCardSubtitle
                                    : AppTypography.smallCardSubtitle)
                                .copyWith(fontSize: isLarge ? 14 : 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });

  static _CardConfig getConfig(CardType type) {
    final baseConfig = _BaseCardConfigs.getBaseConfig(type);
    return _CardConfig(
      backgroundColor: baseConfig.backgroundColor,
      mainIcon: baseConfig.mainIcon,
      backgroundImage: baseConfig.backgroundImage,
    );
  }
}

class _BaseCardConfigs {
  static final Map<CardType, _CardBaseConfig> _configs = {
    CardType.identify: _CardBaseConfig(
      backgroundColor: AppColors.identifyCard,
      mainIcon: 'assets/icons/ic_identify.svg',
      backgroundImage: 'assets/images/bg_identify.png',
    ),
    CardType.diagnose: _CardBaseConfig(
      backgroundColor: AppColors.diagnoseCard,
      mainIcon: 'assets/icons/ic_diagnose.svg',
      backgroundImage: 'assets/images/bg_diagnose.png',
    ),
    CardType.water: _CardBaseConfig(
      backgroundColor: AppColors.waterCalculatorCard,
      mainIcon: 'assets/icons/ic_water_calc.svg',
      backgroundImage: 'assets/images/bg_water_calc.png',
    ),
    CardType.light: _CardBaseConfig(
      backgroundColor: AppColors.lightMeterCard,
      mainIcon: 'assets/icons/ic_light_meter.svg',
      backgroundImage: 'assets/images/bg_light_meter.png',
    ),
  };

  static _CardBaseConfig getBaseConfig(CardType type) {
    return _configs[type] ?? _configs[CardType.identify]!;
  }
}

class _CardBaseConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardBaseConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });
}*/


// Before Refactoring 12/03/26 - 02:30pm
/*import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../utils/app_types.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final CardSize size;
  final CardType type;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _CardConfig.getConfig(type, size);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge = size == CardSize.large;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ONLY CHANGE 1: Width becomes percentage-based
        width: isLarge ? screenWidth * 0.9 : screenWidth * 0.44,
        // Height remains FIXED (165/100) - this is good
        height: isLarge ? 100 : 165,
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Background Image - YOUR EXACT OPACITY (0.9) preserved
            if (config.backgroundImage != null)
              Positioned(
                bottom: isLarge ? -24 : -18,
                right: isRtl ? null : (isLarge ? -2 : -1),
                left: isRtl ? (isLarge ? -2 : -1) : null,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(isRtl ? -1.0 : 1.0, 1.0),
                  child: Opacity(
                    opacity: 0.9, // YOUR EXACT OPACITY - preserved
                    child: Image.asset(
                      config.backgroundImage!,
                      // Background size remains FIXED (148/155) - this is good
                      width: isLarge ? 148 : 155,
                      height: isLarge ? 148 : 155,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

            // Content - YOUR EXACT PADDING preserved
            Padding(
              padding: EdgeInsets.only(
                left: isRtl ? 0 : (isLarge ? 19.0 : 11.0),
                right: isRtl ? (isLarge ? 19.0 : 11.0) : 0,
                top: isLarge ? 16 : 18,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon - YOUR EXACT SIZES preserved
                        SvgPicture.asset(
                          config.mainIcon,
                          width: isLarge ? 28 : 36,
                          height: isLarge ? 28 : 36,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        // Spacing - YOUR EXACT VALUES preserved
                        SizedBox(height: isLarge ? 8 : 45),
                        // Title - YOUR EXACT STYLES preserved
                        Text(
                          title,
                          style: (isLarge
                              ? AppTypography.featureCardTitle
                              : AppTypography.smallCardTitle).copyWith(
                            fontSize: isLarge ? 18 : 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Spacing - YOUR EXACT VALUES preserved
                        SizedBox(height: isLarge ? 3 : 4),
                        // Subtitle - YOUR EXACT STYLES preserved
                        Text(
                          subtitle,
                          style: (isLarge
                              ? AppTypography.featureCardSubtitle
                              : AppTypography.smallCardSubtitle).copyWith(
                            fontSize: isLarge ? 14 : 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true, 
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EXACT same config classes - NO CHANGES needed
class _CardConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });

  static _CardConfig getConfig(CardType type, CardSize size) {
    final baseConfig = _BaseCardConfigs.getBaseConfig(type);
    return _CardConfig(
      backgroundColor: baseConfig.backgroundColor,
      mainIcon: baseConfig.mainIcon,
      backgroundImage: baseConfig.backgroundImage,
    );
  }
}

class _BaseCardConfigs {
  static final Map<CardType, _CardBaseConfig> _configs = {
    CardType.identify: _CardBaseConfig(
      backgroundColor: AppColors.identifyCard,
      mainIcon: 'assets/icons/ic_identify.svg',
      backgroundImage: 'assets/images/bg_identify.png',
    ),
    CardType.diagnose: _CardBaseConfig(
      backgroundColor: AppColors.diagnoseCard,
      mainIcon: 'assets/icons/ic_diagnose.svg',
      backgroundImage: 'assets/images/bg_diagnose.png',
    ),
    CardType.water: _CardBaseConfig(
      backgroundColor: AppColors.waterCalculatorCard,
      mainIcon: 'assets/icons/ic_water_calc.svg',
      backgroundImage: 'assets/images/bg_water_calc.png',
    ),
    CardType.light: _CardBaseConfig(
      backgroundColor: AppColors.lightMeterCard,
      mainIcon: 'assets/icons/ic_light_meter.svg',
      backgroundImage: 'assets/images/bg_light_meter.png',
    ),
  };

  static _CardBaseConfig getBaseConfig(CardType type) {
    return _configs[type] ?? _configs[CardType.identify]!;
  }
}

class _CardBaseConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardBaseConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });
}*/


/* // -------- Need to improve sizes ------
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../utils/app_types.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final CardSize size;
  final CardType type;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _CardConfig.getConfig(type, size);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge = size == CardSize.large;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? screenWidth * 0.9 : screenWidth * 0.44,
        height: isLarge ? 100 : 165,
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Background Image
            if (config.backgroundImage != null)
              Positioned(
                bottom: isLarge ? -24 : -18,
                right: isRtl ? null : (isLarge ? -2 : -1),
                left: isRtl ? (isLarge ? -2 : -1) : null,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(isRtl ? -1.0 : 1.0, 1.0),
                  child: Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      config.backgroundImage!,
                      width: isLarge ? 148 : 155,
                      height: isLarge ? 148 : 155,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: EdgeInsets.only(
                left: isRtl ? 0 : (isLarge ? 19.0 : 11.0),
                right: isRtl ? (isLarge ? 19.0 : 11.0) : 0,
                top: isLarge ? 16 : 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          config.mainIcon,
                          width: isLarge ? 28 : 36,
                          height: isLarge ? 28 : 36,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(height: isLarge ? 8 : 36),
                        Text(
                          title,
                          style: (isLarge
                              ? AppTypography.featureCardTitle
                              : AppTypography.smallCardTitle).copyWith(
                            fontSize: isLarge ? 18 : 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isLarge ? 3 : 4),
                        Text(
                          subtitle,
                          style: (isLarge
                              ? AppTypography.featureCardSubtitle
                              : AppTypography.smallCardSubtitle).copyWith(
                            fontSize: isLarge ? 14 : 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });

  static _CardConfig getConfig(CardType type, CardSize size) {
    final baseConfig = _BaseCardConfigs.getBaseConfig(type);
    return _CardConfig(
      backgroundColor: baseConfig.backgroundColor,
      mainIcon: baseConfig.mainIcon,
      backgroundImage: baseConfig.backgroundImage,
    );
  }
}

class _BaseCardConfigs {
  static final Map<CardType, _CardBaseConfig> _configs = {
    CardType.identify: _CardBaseConfig(
      backgroundColor: AppColors.identifyCard,
      mainIcon: 'assets/icons/ic_identify.svg',
      backgroundImage: 'assets/images/bg_identify.png',
    ),
    CardType.diagnose: _CardBaseConfig(
      backgroundColor: AppColors.diagnoseCard,
      mainIcon: 'assets/icons/ic_diagnose.svg',
      backgroundImage: 'assets/images/bg_diagnose.png',
    ),
    CardType.water: _CardBaseConfig(
      backgroundColor: AppColors.waterCalculatorCard,
      mainIcon: 'assets/icons/ic_water_calc.svg',
      backgroundImage: 'assets/images/bg_water_calc.png',
    ),
    CardType.light: _CardBaseConfig(
      backgroundColor: AppColors.lightMeterCard,
      mainIcon: 'assets/icons/ic_light_meter.svg',
      backgroundImage: 'assets/images/bg_light_meter.png',
    ),
  };

  static _CardBaseConfig getBaseConfig(CardType type) {
    return _configs[type] ?? _configs[CardType.identify]!;
  }
}

class _CardBaseConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardBaseConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });
}*/

/*// --------- Hardcode Correct feature card --------
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../utils/app_types.dart';
//import '../../../l10n/app_localizations.dart';
//import 'package:flutter/rendering.dart' show Directionality;


class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final CardSize size;
  final CardType type;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _CardConfig.getConfig(type, size);
    
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _getWidth(context),
        height: _getHeight(context),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack( 
          children: [
             // Background Image - Flipped for RTL
            if (config.backgroundImage != null)
              Align(
  alignment: Directionality.of(context) == TextDirection.rtl
      ? (type == CardType.light 
          ? Alignment.bottomLeft 
          : (size == CardSize.large ? Alignment.centerLeft : Alignment.bottomLeft))
      : (type == CardType.light 
          ? Alignment.bottomRight 
          : (size == CardSize.large ? Alignment.centerRight : Alignment.bottomRight)),
               
               
                       child: Transform.translate(
                         offset: Offset(
                           0,
      type == CardType.light 
          ? ResponsiveHelper.responsiveHeight(18, context) // Move 15px down
          : 0,
    ),
    child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0, 1.0),


                child: Opacity(
               opacity: 0.9, // PRECISE OPACITY - Matches reference screenshot (40%)
                child: Image.asset(
                  config.backgroundImage!,
                  width: config.backgroundSize,
                  height: config.backgroundSize,
                  fit: BoxFit.contain,
               ),
          ),
        ),
      ),
              ),
           // Main Content 
    Padding(
      padding: EdgeInsets.only(
       
        left: Directionality.of(context) == TextDirection.rtl
        ? config.contentPadding.left + 24.0 // Extra left padding for RTL
        : config.contentPadding.left,
      right: Directionality.of(context) == TextDirection.rtl
        ? 12.0  // Add right padding for RTL
        : 0.0,
        top: config.contentPadding.top,
       //  bottom: config.contentPadding.bottom,
      ),

          child: Row(
        children: [
          // Icon and text in a Column for RTL/LTR consistency
               Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [

               // Icon
                 SvgPicture.asset(
                    config.mainIcon,
                    width: config.iconSize,
                    height: config.iconSize,
                    color: AppColors.white,
                  ),
                
                
                SizedBox(height: config.titleSpacing),
                
                // Title 
                Container(
                  constraints: BoxConstraints(
                    maxWidth: size == CardSize.large 
                        ? ResponsiveHelper.responsiveWidth(180, context)
                        : ResponsiveHelper.responsiveWidth(140, context),
                  ),
                  child: Text(
                    title,
                    style: config.titleStyle.copyWith(
                      fontSize: ResponsiveHelper.responsiveFontSize(18, context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: config.subtitleSpacing),
                
                // Subtitle 
                Container(
                  constraints: BoxConstraints(
                    maxWidth: size == CardSize.large 
                        ? ResponsiveHelper.responsiveWidth(180, context)
                        : ResponsiveHelper.responsiveWidth(140, context),
                  ),
                  child: Text(
                    subtitle,
                    style: config.subtitleStyle.copyWith(
                      fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getWidth(BuildContext context) {
    return size == CardSize.large
        ? ResponsiveHelper.responsiveWidth(343, context)
        : ResponsiveHelper.responsiveWidth(166, context);
  }

  double _getHeight(BuildContext context) {
    return size == CardSize.large
        ? ResponsiveHelper.responsiveHeight(100, context)
        : ResponsiveHelper.responsiveHeight(165, context);
  }
}

class _CardConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;
  final double backgroundBottom;
  final double backgroundRight;
  final double backgroundSize;
  final double iconSize;
  final EdgeInsets contentPadding;
  final double titleSpacing;
  final double subtitleSpacing;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;

  _CardConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
    required this.backgroundBottom,
    required this.backgroundRight,
    required this.backgroundSize,
    required this.iconSize,
    required this.contentPadding,
    required this.titleSpacing,
    required this.subtitleSpacing,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  static _CardConfig getConfig(CardType type, CardSize size) {
    final isLarge = size == CardSize.large;
    
    final baseConfig = _BaseCardConfigs.getBaseConfig(type);
    
    return _CardConfig(
      backgroundColor: baseConfig.backgroundColor,
      mainIcon: baseConfig.mainIcon,
      backgroundImage: baseConfig.backgroundImage,
      // Positioning optimized for background elements
      backgroundBottom: isLarge ? -24 : -18,
      backgroundRight: isLarge ? -2 : -1,
      backgroundSize: isLarge ? 148 : 155,
      iconSize: isLarge ? 28 : 36,
      contentPadding: isLarge 
          ? const EdgeInsets.only(left: 19, top: 16)
          : const EdgeInsets.only(left: 11, top: 20),
      titleSpacing: isLarge ? 8 : 36,
      subtitleSpacing: isLarge ? 3 : 4,
      titleStyle: isLarge ? AppTypography.featureCardTitle : AppTypography.smallCardTitle,
      subtitleStyle: isLarge ? AppTypography.featureCardSubtitle : AppTypography.smallCardSubtitle,
    );
  }
}

class _BaseCardConfigs {
  static final Map<CardType, _CardBaseConfig> _configs = {
    CardType.identify: _CardBaseConfig(
      backgroundColor: AppColors.identifyCard,
      mainIcon: 'assets/icons/ic_identify.svg',
      backgroundImage: 'assets/images/bg_identify.png', 
    ),
    CardType.diagnose: _CardBaseConfig(
      backgroundColor: AppColors.diagnoseCard,
      mainIcon: 'assets/icons/ic_diagnose.svg',
      backgroundImage: 'assets/images/bg_diagnose.png', 
    ),
    CardType.water: _CardBaseConfig(
      backgroundColor: AppColors.waterCalculatorCard,
      mainIcon: 'assets/icons/ic_water_calc.svg',
      backgroundImage: 'assets/images/bg_water_calc.png', 
    ),
    CardType.light: _CardBaseConfig(
      backgroundColor: AppColors.lightMeterCard,
      mainIcon: 'assets/icons/ic_light_meter.svg',
      backgroundImage: 'assets/images/bg_light_meter.png', 
    ),
  };

  static _CardBaseConfig getBaseConfig(CardType type) {
    return _configs[type] ?? _configs[CardType.identify]!;
  }
}

class _CardBaseConfig {
  final Color backgroundColor;
  final String mainIcon;
  final String? backgroundImage;

  _CardBaseConfig({
    required this.backgroundColor,
    required this.mainIcon,
    this.backgroundImage,
  });
}*/