import 'package:flutter/material.dart';
import '../../../utils/localized_data_helper.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';



// Reusable Diagnosis Card
class DiagnosisCard extends StatelessWidget {
  final String title;
  final Widget content;
  final Color? backgroundColor;

  const DiagnosisCard({
    super.key,
    required this.title,
    required this.content,
    this.backgroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,  //  This will receive localized string from parent
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.responsiveFontSize(16, context),
              color: AppColors.black,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          content,
        ],
      ),
    );
  }
}

// Reusable Severity Indicator with Progress Bar
class SeverityIndicator extends StatelessWidget {
  final String severityLevel;
  final String symptoms;

  const SeverityIndicator({
    super.key,
    required this.severityLevel,
    required this.symptoms,
  });

  double _getProgressValue(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild': return 0.25;
      case 'moderate': return 0.5;
      case 'severe': return 0.75;
      case 'critical': return 1.0;
      default: return 0.5;
    }
  }

  Color _getSeverityColor(String severity) {
  debugPrint('🎯 SeverityIndicator: Getting color for severity "$severity"');
  switch (severity.toLowerCase()) {

    case 'none': 
     debugPrint('🎯 SeverityIndicator: Color = Gray (None)');
      return AppColors.mediumGray; // Gray for no plant
    case 'mild': 
     debugPrint('🎯 SeverityIndicator: Color = Green (Mild)');
      return Color(0xFF4CAF50); // Appropriate Green
    case 'moderate': 
     debugPrint('🎯 SeverityIndicator: Color = Lime (Moderate)');
      return Color(0xFFCDDC39); // Yellowish Greenish (Lime)
    case 'severe': 
     debugPrint('🎯 SeverityIndicator: Color = Red (Severe)');
      return Color(0xFFF44336); // Red
    case 'critical': 
     debugPrint('🎯 SeverityIndicator: Color = Dark Red (Critical)');
      return Color(0xFFB71C1C); // Dark Red
    case 'healthy':
     debugPrint('🎯 SeverityIndicator: Color = Green (Healthy)');
      return Color(0xFF4CAF50); // Green for healthy plants
    default: 
      debugPrint('🎯 SeverityIndicator: Color = Lime (Default for "$severity")');
      return Color(0xFFCDDC39); // Fallback to moderate
  }
}

String _getLocalizedSeverity(AppLocalizations l10n, String severity) {
    switch (severity.toLowerCase()) {
      case 'mild': return l10n.widget_severity_mild;
      case 'moderate': return l10n.widget_severity_moderate;
      case 'severe': return l10n.widget_severity_severe;
      case 'critical': return l10n.widget_severity_critical;
      case 'healthy': return l10n.widget_severity_healthy;
      default: return severity.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);
    debugPrint('🎯 SeverityIndicator: severityLevel = "$severityLevel"');

   if (severityLevel.toLowerCase() == 'none') {
     debugPrint('🎯 SeverityIndicator: Showing "None" UI (no plant detected)');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
        //  'Severity Assessment',
         l10n.widget_severity_assessment,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.responsiveFontSize(16, context),
            color: AppColors.black,
          ),
        ),
        SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
        Text(
        //  'No plant detected in image',
          l10n.widget_no_plant_detected,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveHelper.responsiveFontSize(14, context),
            color: AppColors.darkGray,
            height: 1.4,
          ),
        ),
      ],
    );
  }

    debugPrint('🎯 SeverityIndicator: Showing normal severity UI for "$severityLevel"');
    final progressValue = _getProgressValue(severityLevel);
    final severityColor = _getSeverityColor(severityLevel);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Severity Badge and Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
            //  'Severity Level',
             l10n.widget_severity_level, 
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                color: AppColors.black,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.responsiveWidth(8, context),
                vertical: ResponsiveHelper.responsiveHeight(4, context),
              ),
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
             //   severityLevel.toUpperCase(),
               _getLocalizedSeverity(l10n, severityLevel),
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.responsiveFontSize(10, context),
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
        
        // Progress Bar
        Stack(
          children: [
            // Track
            Container(
              width: double.infinity,
              height: ResponsiveHelper.responsiveHeight(8, context),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // Progress
            Container(
              width: MediaQuery.of(context).size.width * progressValue,
              height: ResponsiveHelper.responsiveHeight(8, context),
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // Thumb
         /*   Positioned(
              left: MediaQuery.of(context).size.width * progressValue - 8,
              top: ResponsiveHelper.responsiveHeight(0, context),
              child: Container(
                width: ResponsiveHelper.responsiveWidth(16, context),
                height: ResponsiveHelper.responsiveWidth(16, context),
                decoration: BoxDecoration(
                  color: severityColor,
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          */  
          ],
        ),
        


        SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
        
         
        // Symptoms - TranslatedText widget
        TranslatedText(
         symptoms, 
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveHelper.responsiveFontSize(14, context),
            color: AppColors.darkGray,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// Reusable Treatment Item
class TreatmentItem extends StatelessWidget {
  final String treatment;
  final String duration;
  final String frequency;

  const TreatmentItem({
    super.key,
    required this.treatment,
    required this.duration,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
     final l10n = AppLocalizations.of(context);

  
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(12, context)),
      margin: EdgeInsets.only(bottom: ResponsiveHelper.responsiveHeight(8, context)),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.responsiveWidth(6, context),
                  vertical: ResponsiveHelper.responsiveHeight(2, context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                //  'Treatment',
                 l10n.widget_treatment_badge,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w500,
                    fontSize: ResponsiveHelper.responsiveFontSize(10, context),
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
         
         
          // Treatment text - Use TranslatedText
          TranslatedText(
          treatment, 
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.responsiveFontSize(14, context),
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveHeight(4, context)),
         

         // Duration • Frequency - Use TranslatedText for each part
          Row(
            children: [
              TranslatedText(
                duration,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w400,
              fontSize: ResponsiveHelper.responsiveFontSize(12, context),
              color: AppColors.mediumGray,
            ),
          ),
       
       
                     Text(
                ' • ',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w400,
                  fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                  color: AppColors.mediumGray,
                ),
              ),
              TranslatedText(
                frequency,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w400,
                  fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable Checklist Item
class ChecklistItem extends StatelessWidget {
  final String text;

  const ChecklistItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          color: AppColors.primaryGreen,
          size: ResponsiveHelper.responsiveWidth(16, context),
        ),
        SizedBox(width: ResponsiveHelper.responsiveWidth(8, context)),
        Expanded(

          child: TranslatedText(
            text, 
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.responsiveFontSize(14, context),
              color: AppColors.darkGray,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}


// TranslatedText Widget - Handles async translation
// If you want widgets to handle their own translation
class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  
  const TranslatedText(this.text, {super.key, this.style});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: LocalizedDataHelper.localizeText(context, text),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!, style: style);
        }
        return Text(text, style: style); // Fallback
      },
    );
  }
}

