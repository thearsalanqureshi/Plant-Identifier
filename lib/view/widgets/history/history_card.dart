import 'dart:io';
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
}