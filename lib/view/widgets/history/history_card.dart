import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../data/models/history_model.dart';
import '../../../data/services/translation_service.dart';
import '../../../l10n/app_localizations.dart';

class HistoryCard extends StatelessWidget {
  final ScanHistory scan;
  final VoidCallback onTap;
  final VoidCallback onMorePressed;

  const HistoryCard({
    super.key,
    required this.scan,
    required this.onTap,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;
    final imageSize = isTablet ? 84.0 : 56.0;
    final horizontalPadding = isTablet ? 20.0 : 16.0;
    final verticalPadding = isTablet ? 18.0 : 14.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 92),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGray.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Row(
              children: [
                _buildPlantImage(context, imageSize),
                const SizedBox(width: 12),
                Expanded(child: _buildPlantInfo(context)),
                const SizedBox(width: 8),
                _buildMoreButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantImage(BuildContext context, double imageSize) {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(imageSize / 2),
      ),
      child: scan.imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(imageSize / 2),
              child: Image.file(
                File(scan.imagePath!),
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.photo,
              color: AppColors.primaryGreen,
              size: imageSize * 0.42,
            ),
    );
  }

  Widget _buildPlantInfo(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          scan.plantName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildProfileBadge(context, scan),
            Text(
              _formatTimestamp(scan.timestamp, context),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileBadge(BuildContext context, ScanHistory scan) {
    String badgeText;
    Color badgeColor;

    switch (scan.type) {
      case 'identify':
        badgeText = AppLocalizations.of(context).widget_history_badge_identified;
        badgeColor = AppColors.identifyCard;
        break;
      case 'diagnose':
        badgeText = AppLocalizations.of(context).widget_history_badge_diagnosed;
        badgeColor = AppColors.diagnoseCard;
        break;
      case 'water':
        badgeText = AppLocalizations.of(context).widget_history_badge_calculated;
        badgeColor = AppColors.waterCalculatorCard;
        break;
      case 'light':
        badgeText = AppLocalizations.of(context).widget_history_badge_measured;
        badgeColor = AppColors.lightMeterCard;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        badgeText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w900,
          fontSize: 10,
          color: AppColors.white,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onMorePressed,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: AppColors.mediumGray, size: 22),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context).widget_history_timestamp_just_now;
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${AppLocalizations.of(context).widget_history_timestamp_min_ago}';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} ${AppLocalizations.of(context).widget_history_timestamp_hours_ago}';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} ${AppLocalizations.of(context).widget_history_timestamp_days_ago}';
    }

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'en') {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return FutureBuilder<String>(
      future: TranslationService.translateText(text, locale),
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}


// Before Refactoring 12/03/26 - 02:45pm
/*import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import '../../../../utils/responsive_helper.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../data/models/history_model.dart';
import '../../../data/services/translation_service.dart';
import '../../../l10n/app_localizations.dart';

class HistoryCard extends StatelessWidget {
  final ScanHistory scan;
  final VoidCallback onTap;
  final VoidCallback onMorePressed;
  
  const HistoryCard({
    super.key,
    required this.scan,
    required this.onTap,
    required this.onMorePressed,
  });

  @override
Widget build(BuildContext context) {
  return Container(
    // REMOVE fixed width/height - use constraints instead
    constraints: BoxConstraints(
      minHeight: ResponsiveHelper.responsiveHeight(80, context),
      maxWidth: ResponsiveHelper.responsiveWidth(343, context),
    ),
    width: double.infinity, // Use full available width
    margin: EdgeInsets.only(bottom: ResponsiveHelper.responsiveHeight(12, context)),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.mediumGray.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
          child: Row(
            children: [
              // Plant Image - keep this fixed size
              _buildPlantImage(context),
              
              SizedBox(width: ResponsiveHelper.responsiveWidth(12, context)),
              
              // Plant Info - make this flexible
              Expanded( // ← CRITICAL: This allows text to wrap
                child: _buildPlantInfo(context),
              ),
              
              // More Button - keep fixed
              _buildMoreButton(context),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildPlantImage(BuildContext context) {
    
    return Container(
      width: ResponsiveHelper.responsiveWidth(50, context),
      height: ResponsiveHelper.responsiveWidth(50, context),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(25),
      ),
      child: scan.imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.file(
                File(scan.imagePath!),
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.photo,
              color: AppColors.primaryGreen,
              size: ResponsiveHelper.responsiveWidth(24, context),
            ),
    );
  }

  Widget _buildPlantInfo(BuildContext context) {
     final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Plant Name
       // Text(
        TranslatedText(
          scan.plantName,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.responsiveHeight(4, context)),
        
        Row(
          children: [
            
           // if (scan.isSaved) _buildProfileBadge(context, scan),
              _buildProfileBadge(context, scan), 
            
            Text(
              _formatTimestamp(scan.timestamp, context),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ],
    );
  }

Widget _buildProfileBadge(BuildContext context, ScanHistory scan) {
    final l10n = AppLocalizations.of(context);

  
  // Determine badge text and color based on scan type
  String badgeText;
  Color badgeColor;
  
  switch (scan.type) {
    case 'identify':
  //  badgeText = 'IDENTIFIED';
      badgeText = AppLocalizations.of(context).widget_history_badge_identified;
      badgeColor = AppColors.identifyCard;
      break;
    case 'diagnose':
  //  badgeText = 'DIAGNOSED';
      badgeText = AppLocalizations.of(context).widget_history_badge_diagnosed;
      badgeColor = AppColors.diagnoseCard;
      break;
    case 'water':
  //  badgeText = 'CALCULATED';
      badgeText = AppLocalizations.of(context).widget_history_badge_calculated;
      badgeColor = AppColors.waterCalculatorCard;
      break;
    case 'light':
  //  badgeText = 'MEASURED';
      badgeText = AppLocalizations.of(context).widget_history_badge_measured;
      badgeColor = AppColors.lightMeterCard;
      break;
    default:
      return SizedBox.shrink(); // Hide badge for unknown types
  }
  
  // Calculate dynamic width based on text length
  final double badgeWidth = badgeText.length > 9 ? 70 : 55;
  
  return Container(
    width: ResponsiveHelper.responsiveWidth(badgeWidth, context),
    height: ResponsiveHelper.responsiveHeight(10, context),
    margin: EdgeInsets.only(right: ResponsiveHelper.responsiveWidth(8, context)),
    decoration: BoxDecoration(
      color: badgeColor,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Center(
      child: Text(
        badgeText,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w900,
          fontSize: ResponsiveHelper.responsiveFontSize(8, context),
          color: AppColors.white,
        ),
      ),
    ),
  );
}

  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: onMorePressed,
      child: Container(
        width: ResponsiveHelper.responsiveWidth(24, context),
        height: ResponsiveHelper.responsiveWidth(24, context),
        child: Icon(
          Icons.more_vert,
          color: AppColors.mediumGray,
          size: ResponsiveHelper.responsiveWidth(20, context),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, BuildContext context) {
     final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1)
  //   return 'Just now';
    return AppLocalizations.of(context).widget_history_timestamp_just_now;


 //  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes} ${AppLocalizations.of(context).widget_history_timestamp_min_ago}';

 //   if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inHours < 24) return '${difference.inHours} ${AppLocalizations.of(context).widget_history_timestamp_hours_ago}';
   
 //   if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 7) return '${difference.inDays} ${AppLocalizations.of(context).widget_history_timestamp_days_ago}';


    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const TranslatedText(this.text, {
    super.key, 
    this.style, 
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    if (locale == 'en') {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    
    return FutureBuilder<String>(
      future: TranslationService.translateText(text, locale),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        }
        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}*/