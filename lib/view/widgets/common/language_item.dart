import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../utils/constants.dart';
import '../../../data/models/language_model.dart';

class LanguageItem extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageItem({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
      final localizations = AppLocalizations.of(context)!;
      
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveHelper.responsiveWidth(343, context),
        height: ResponsiveHelper.responsiveHeight(70, context),
        decoration: BoxDecoration(
          color: AppColors.languageCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.languageCardBorder,
            width: 0.75,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.responsiveWidth(16, context),
          ),
          child: Row(
            children: [
              // Language Name and Native Name
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    //  language.name,
                      _getLocalizedName(localizations, language.code),
                      style: AppTypography.languageItem.copyWith(
                        fontSize: ResponsiveHelper.responsiveFontSize(17, context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Checkmark Icon - Shows checked/unchecked based on selection
              SvgPicture.asset(
                isSelected ? AppConstants.checkedIcon : AppConstants.uncheckedIcon,
                width: ResponsiveHelper.responsiveWidth(24, context),
                height: ResponsiveHelper.responsiveHeight(24, context),
                color: isSelected ? AppColors.tickIconColor : AppColors.mediumGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
   String _getLocalizedName(AppLocalizations l10n, String code) {
    switch (code) {
    case 'en': return l10n.english;        // Changed from languageEnglish
    case 'ur': return l10n.urdu;            // Changed from languageUrdu
    case 'de': return l10n.german;          // Changed from languageGerman
    case 'fr': return l10n.french;          // Changed from languageFrench
    case 'ar': return l10n.arabic;          // Changed from languageArabic
    case 'es': return l10n.spanish;         // Changed from languageSpanish
    case 'ja': return l10n.japanese;        // Changed from languageJapanese
    case 'ko': return l10n.korean; 
      default: return language.name;
    }
  }
}