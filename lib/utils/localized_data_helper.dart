import 'package:flutter/material.dart';
import '../data/services/translation_service.dart';


class LocalizedDataHelper {
  // Single method to localize ANY text dynamically
  static Future<String> localizeText(BuildContext context, String text) async {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'en') return text;
    return await TranslationService.translateText(text, locale);
  }
  
  // Localize entire diagnosis data map
  static Future<Map<String, dynamic>> localizeDiagnosisData(
    BuildContext context, 
    Map<String, dynamic> data
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'en') return data;
    
    final localized = Map<String, dynamic>.from(data);
    
    // Translate all text fields
    if (localized['plantName'] != null) {
      localized['plantName'] = await TranslationService.translateText(localized['plantName'], locale);
    }
    if (localized['diseaseName'] != null) {
      localized['diseaseName'] = await TranslationService.translateText(localized['diseaseName'], locale);
    }
    if (localized['symptoms'] != null) {
      localized['symptoms'] = await TranslationService.translateText(localized['symptoms'], locale);
    }
    if (localized['immediateActions'] != null) {
      localized['immediateActions'] = await TranslationService.translateText(localized['immediateActions'], locale);
    }
    if (localized['treatmentPlan'] != null) {
      localized['treatmentPlan'] = await TranslationService.translateText(localized['treatmentPlan'], locale);
    }
    if (localized['dailyMonitoring'] != null) {
      localized['dailyMonitoring'] = await TranslationService.translateText(localized['dailyMonitoring'], locale);
    }
    if (localized['expectedRecovery'] != null) {
      localized['expectedRecovery'] = await TranslationService.translateText(localized['expectedRecovery'], locale);
    }
    
    return localized;
  }
}



/*// ---------- 1st ---------- 
import 'package:flutter/material.dart';
import '../data/services/translation_service.dart';


class LocalizedDataHelper {
  // Single method to localize ANY text dynamically
  static Future<String> localizeText(BuildContext context, String text) async {
    final locale = Localizations.localeOf(context).languageCode;
    
    if (locale == 'en') return text;
    
    // Use Gemini to translate
    return await TranslationService.translateText(text, locale);
  }
  
  // Specialized for plant names (can be cached for performance)
  static Future<String> getLocalizedPlantName(BuildContext context, String plantName) async {
    return await localizeText(context, plantName);
  }
  
  // Specialized for disease names
  static Future<String> getLocalizedDiseaseName(BuildContext context, String disease) async {
    return await localizeText(context, disease);
  }
  
  // Specialized for symptoms
  static Future<String> getLocalizedSymptoms(BuildContext context, String symptoms) async {
    return await localizeText(context, symptoms);
  }
  
  // Specialized for treatment
  static Future<String> getLocalizedTreatment(BuildContext context, String treatment) async {
    return await localizeText(context, treatment);
  }
  
  // Specialized for maintenance text
  static Future<String> getLocalizedMaintenanceText(BuildContext context, String text) async {
    return await localizeText(context, text);
  }
  
  // Specialized for checklist items
  static Future<String> getLocalizedChecklistItem(BuildContext context, String item) async {
    return await localizeText(context, item);
  }
  
  // Specialized for expected recovery
  static Future<String> getLocalizedExpectedRecovery(BuildContext context, String recovery) async {
    return await localizeText(context, recovery);
  }
  
  // Specialized for actions
  static Future<String> getLocalizedAction(BuildContext context, String action) async {
    return await localizeText(context, action);
  }
  
  // Localize entire diagnosis data map
  static Future<Map<String, dynamic>> localizeDiagnosisData(
    BuildContext context, 
    Map<String, dynamic> data
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'en') return data;
    
    final localized = Map<String, dynamic>.from(data);
    
    // Translate all text fields
    if (localized['plantName'] != null) {
      localized['plantName'] = await translateText(localized['plantName'], locale);
    }
    if (localized['diseaseName'] != null) {
      localized['diseaseName'] = await translateText(localized['diseaseName'], locale);
    }
    if (localized['symptoms'] != null) {
      localized['symptoms'] = await translateText(localized['symptoms'], locale);
    }
    if (localized['immediateActions'] != null) {
      localized['immediateActions'] = await translateText(localized['immediateActions'], locale);
    }
    if (localized['treatmentPlan'] != null) {
      localized['treatmentPlan'] = await translateText(localized['treatmentPlan'], locale);
    }
    if (localized['dailyMonitoring'] != null) {
      localized['dailyMonitoring'] = await translateText(localized['dailyMonitoring'], locale);
    }
    if (localized['expectedRecovery'] != null) {
      localized['expectedRecovery'] = await translateText(localized['expectedRecovery'], locale);
    }
    
    return localized;
  }
}*/