import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _apiKey = "AIzaSyDBclzBXD5TkzWB4Dcnud2O4yGOHNRMkTw"; 
  static const String _model = 'gemini-2.5-flash';
  
  static Future<String> translateText(String text, String targetLanguage) async {
    if (targetLanguage == 'en') return text;
    
    try {
      final prompt = '''
Translate the following text to $targetLanguage. 
Return ONLY the translation, no explanations, no extra text.

Text to translate: "$text"
''';
      
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1/models/$_model:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 1500,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated = data['candidates'][0]['content']['parts'][0]['text'].trim();
        return translated;
      }
      
      return text; // Fallback
    } catch (e) {
    //  debugPrint('Translation failed: $e');
      return text; // Fallback
    }
  }
  
  // Batch translate multiple texts
  static Future<Map<String, String>> batchTranslate(
    Map<String, String> texts, 
    String targetLanguage
  ) async {
    if (targetLanguage == 'en') return texts;
    
    final results = <String, String>{};
    
    for (final entry in texts.entries) {
      results[entry.key] = await translateText(entry.value, targetLanguage);
    }
    
    return results;
  }

  static Future<Map<String, dynamic>> translatePlantData(Map<String, dynamic> data, String targetLanguage) async {
  final translated = Map<String, dynamic>.from(data);
  
  if (data['plantName'] != null) {
    translated['plantName'] = await translateText(data['plantName'], targetLanguage);
  }
  if (data['scientificName'] != null) {
    translated['scientificName'] = await translateText(data['scientificName'], targetLanguage);
   }
  if (data['description'] != null) {
    translated['description'] = await translateText(data['description'], targetLanguage);
   }
  if (data['temperature'] != null) {
    translated['temperature'] = await translateText(data['temperature'], targetLanguage);
   }
  if (data['light'] != null) {
    translated['light'] = await translateText(data['light'], targetLanguage);
   }
  if (data['soil'] != null) {
    translated['soil'] = await translateText(data['soil'], targetLanguage);
   }
  if (data['humidity'] != null) {
    translated['humidity'] = await translateText(data['humidity'], targetLanguage);
   }
  if (data['watering'] != null) {
    translated['watering'] = await translateText(data['watering'], targetLanguage);
   }
  if (data['fertilizing'] != null) {
    translated['fertilizing'] = await translateText(data['fertilizing'], targetLanguage);
   }
  if (data['toxicity'] != null) {
    translated['toxicity'] = await translateText(data['toxicity'], targetLanguage);
   }
  return translated;
}
  
  
  static Future<Map<String, dynamic>> translateDiagnosisData(Map<String, dynamic> data, String targetLanguage) async {
  final translated = Map<String, dynamic>.from(data);
  
  if (data['plantName'] != null) {
    translated['plantName'] = await translateText(data['plantName'], targetLanguage);
  }
  if (data['diseaseName'] != null) {
    translated['diseaseName'] = await translateText(data['diseaseName'], targetLanguage);
  }
  if (data['symptoms'] != null) {
    translated['symptoms'] = await translateText(data['symptoms'], targetLanguage);
  }
  if (data['immediateActions'] != null) {
    translated['immediateActions'] = await translateText(data['immediateActions'], targetLanguage);
  }
  if (data['treatmentPlan'] != null) {
    translated['treatmentPlan'] = await translateText(data['treatmentPlan'], targetLanguage);
  }
  if (data['dailyMonitoring'] != null) {
    translated['dailyMonitoring'] = await translateText(data['dailyMonitoring'], targetLanguage);
  }
  if (data['expectedRecovery'] != null) {
    translated['expectedRecovery'] = await translateText(data['expectedRecovery'], targetLanguage);
  }
  
  return translated;
}

static Future<Map<String, dynamic>> translateWaterData(Map<String, dynamic> data, String targetLanguage) async {
  final translated = Map<String, dynamic>.from(data);
  
  if (data['plantName'] != null) {
    translated['plantName'] = await translateText(data['plantName'], targetLanguage);
  }
  if (data['explanation'] != null) {
    translated['explanation'] = await translateText(data['explanation'], targetLanguage);
  }
  if (data['frequency'] != null) {
    translated['frequency'] = await translateText(data['frequency'], targetLanguage);
  }
  if (data['bestTime'] != null) {
    translated['bestTime'] = await translateText(data['bestTime'], targetLanguage);
  }
  if (data['tips'] != null && data['tips'] is List) {
    final translatedTips = <String>[];
    for (final tip in data['tips']) {
      translatedTips.add(await translateText(tip, targetLanguage));
    }
    translated['tips'] = translatedTips;
  }
  
  return translated;
}

}