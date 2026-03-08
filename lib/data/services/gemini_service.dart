import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/plant_model.dart';
import '../models/diagnosis_model.dart';
import '../models/water_calculation_model.dart';
import 'analytics_service.dart';

class GeminiService {
  static const String apiKey = "MY_API_KEY";
  static const String model = 'gemini-2.5-flash'; 
  static const Duration timeout = Duration(seconds: 30);

  
  static const Map<String, String> _prompts = {
   
   
    'identify': '''

**STRICT INSTRUCTIONS:** Return ONLY valid, complete JSON. No explanations, no extra text.

If you cannot identify the plant, return this EXACT JSON:
{
  "plantName": "Unidentified Plant",
  "scientificName": "Unknown Species",
  "description": "Unable to identify from provided image. Please ensure plant is clearly visible with good lighting.",
  "temperature": "Varies by plant type",
  "light": "Adjust based on plant response",
  "soil": "Well-draining soil recommended",
  "humidity": "Moderate humidity",
  "watering": "Water when top soil is dry",
  "fertilizing": "Balanced fertilizer during growing season",
  "toxicity": "Safety unknown - use caution"
}

If you CAN identify, return this JSON structure with ALL fields completed:
{
  "plantName": "Common name (e.g., 'Parlor Palm')",
  "scientificName": "Scientific name",
  "description": " Brief description of the plant",
  "temperature": "Ideal temperature range",
  "light": "Light needs",
  "soil": "Soil type",
  "humidity": "Humidity preference",
  "watering": "Watering guidance",
  "fertilizing": "Fertilizer needs",
  "toxicity": "Safety info"
}

Focus on the main plant even if:
- Image is blurry or low quality
- Multiple plants are present  
- Only leaves/stems are visible
- Plant is artificial/decorative
- Background is busy

Return ONLY the JSON object. Nothing before or after.
''',

/*
Identify this plant from the image. Return ONLY valid JSON..

IMPORTANT: Your response must be at least 300 characters long with complete information for all fields.

Focus on the main plant even if:
- Image is blurry or low quality
- Multiple plants are present  
- Only leaves/stems are visible
- Plant is artificial/decorative
- Background is busy

JSON structure:
{
  "plantName": "Common name (e.g., 'Parlor Palm')",
  "scientificName": "Scientific name", 
  "description": "Brief description",
  "temperature": "Ideal temperature range",
  "light": "Light needs",
  "soil": "Soil type",
  "humidity": "Humidity preference", 
  "watering": "Watering guide",
  "fertilizing": "Fertilizer needs",
  "toxicity": "Safety info"
}

Return ONLY the complete JSON object.
'''
*/
    
    'diagnose': '''
FIRST: Identify the plant from the image.  
THEN: Analyze its health.

CRITICAL REQUIREMENTS:
1. Return ONLY valid, complete JSON
2. Ensure ALL strings are properly quoted
3. Ensure ALL brackets and braces are properly closed  
4. No trailing commas before } or ]
5. JSON must be parseable by standard JSON parsers


CRITICAL CHECK 1: If NO plant, tree, leaves, stems, or any plant parts are detected in the image, return:
{
  "plantName": "No Plant Detected",
  "diseaseName": "No Plant in Image",
  "severityLevel": "None",
  "symptoms": "No plant material visible in the image",
  "immediateActions": "Please take a clear photo of a plant",
  "treatmentPlan": "Image does not contain a plant",
  "dailyMonitoring": "Not applicable",
  "expectedRecovery": "Not applicable"
}

CRITICAL CHECK 2: If the plant appears DEAD (brown, withered, dried, no green, brittle, decayed) or SEVERELY DAMAGED (broken stems, extensive rot, complete wilting), return:
- diseaseName: "Plant Death / Severe Damage"
- severityLevel: "Critical"

Focus on the main plant even if:
- Image is blurry or low quality
- Multiple plants are present  
- Only leaves/stems are visible
- Plant is artificial/decorative
- Background is busy


JSON structure:
{
  "plantName": "Plant name",
  "diseaseName": "Disease or 'Healthy' or 'Plant Death / Severe Damage'",
  "severityLevel": "Mild/Moderate/Severe/Critical/None",
  "symptoms": "Visible symptoms",
  "immediateActions": "Quick actions",
  "treatmentPlan": "Treatment steps",
  "dailyMonitoring": "Monitoring guide",
  "expectedRecovery": "Recovery time"
}

PLANT NAME RULES:
- Use common name only (e.g., "Caladium", 'Parlor Palm')
- No botanical names in parentheses
- No extra descriptions
- Be consistent: same plant → same name

Return ONLY the JSON object, nothing else.
''',
    
    'water': '''
Calculate SPECIFIC watering needs for this plant. Be PRECISE.

CONTEXT:
- Plant Location: {location}
- Current Temperature: {temperature}
- User's Watering Frequency: {wateringFrequency}

REQUIREMENTS:
1. FIRST identify the plant from the image
2. THEN calculate water amount based on plant type + context
3. Provide SPECIFIC amounts (e.g., "300-400 ML")
4. Give PRACTICAL tips

Focus on the main plant even if:
- Image is blurry or low quality
- Multiple plants are present  
- Only leaves/stems are visible
- Plant is artificial/decorative
- Background is busy

Return ONLY this JSON:
{
  "plantName": "Actual plant name from image",
  "waterAmount": "Specific amount like 300-400 ML",
  "explanation": "Why this amount based on plant + conditions",
  "frequency": "How often to water", 
  "bestTime": "Best time of day",
  "tips": ["Practical tip 1", "Practical tip 2", "Practical tip 3"]
}

Return ONLY the JSON object.
'''
  };

  // NEW METHOD: Validate API response is actually JSON
bool _isValidJSONResponse(String text) {
  // Too short to be valid plant JSON
  if (text.length < 200) return false;
  
  // Check for common error patterns
  if (text.contains('<html>') || 
      text.contains('<!DOCTYPE') ||
      text.contains('Error:') ||
      text.contains('quota') ||
      text.contains('limit') ||
      text.contains('exceeded')) {
    return false;
  }
  
  // Must contain JSON structure
  return text.contains('{') && text.contains('}');
}

  // SIMPLIFIED API CALL
  Future<String> _callGeminiAPI(
  String prompt,
  String base64Image,
  String feature, {
  int? overrideMaxTokens,
}) async {
     debugPrint('🔧 Calling Gemini API with model: $model for feature: $feature');
    

  final startTime = DateTime.now();
  final imageSizeKB = base64Image.length * 3 / 4 / 1024; // Approximate KB

     try {
        debugPrint('📊 API Call Start - Feature: $feature, Image: ${imageSizeKB.round()}KB');

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // CRITICAL: Request JSON only
      },

      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inlineData': {
                  'mimeType': 'image/jpeg',
                  'data': base64Image
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4, // Higher for better recognition
           'maxOutputTokens': overrideMaxTokens ?? 1500,
          'topP': 0.95, //for better responses
          'topK': 40,   // for better responses
        }
         
         /*
         'safetySettings': [  // ADD THIS to prevent blocks
          {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_NONE'},
          {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
          {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_NONE'},
          {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_NONE'}
        ]
        */


      }),
    //   ).timeout(timeout);
          ).timeout(Duration(seconds: 45)); // Increased timeout

           final processingTime = DateTime.now().difference(startTime).inMilliseconds;

          debugPrint('📊 API Status: ${response.statusCode}, Time: ${processingTime}ms');


            // Check for rate limiting headers
    if (response.headers.containsKey('x-ratelimit-remaining')) {
      debugPrint('Rate limit remaining: ${response.headers['x-ratelimit-remaining']}');
    }

    if (response.statusCode == 429) {

       AnalyticsService.logApiError(
        errorType: 'rate_limit_exceeded',
        statusCode: 429,
        errorDetail: 'Rate limit exceeded',
        feature: feature,
      );
      throw Exception('Rate limit exceeded - please try again in a moment');
    }

    
    if (response.statusCode == 403) {

       AnalyticsService.logApiError(
        errorType: 'quota_exceeded',
        statusCode: 403,
        errorDetail: 'API quota exceeded',
        feature: feature,
      );

      throw Exception('API quota exceeded - check your Google Cloud billing');
    }

    
    if (response.statusCode != 200) {

       AnalyticsService.logApiError(
        errorType: 'http_error',
        statusCode: response.statusCode,
        errorDetail: 'HTTP ${response.statusCode}',
        feature: feature,
      );
      
      debugPrint('API Error: ${response.statusCode}');
      throw Exception('API error: ${response.statusCode}');
    }

    final responseData = jsonDecode(response.body);
    
     
      // Check if there's an error in the response
      if (responseData['error'] != null) {

         AnalyticsService.logApiError(
        errorType: 'api_response_error',
        statusCode: null,
        errorDetail: responseData['error'].toString(),
        feature: feature,
      );

        debugPrint('API returned error: ${responseData['error']}');
        throw Exception('API error: ${responseData['error']['message']}');
      }
     
      if (responseData['candidates'] == null || responseData['candidates'].isEmpty) {
      
       AnalyticsService.logApiError(
        errorType: 'no_candidates',
        statusCode: null,
        errorDetail: 'No candidates in response',
        feature: feature,
      );
      
      throw Exception('No response from AI');
    }

  //  final text = responseData['candidates'][0]['content']['parts'][0]['text'];
      final parts = (responseData['candidates'][0]['content']['parts'] as List<dynamic>? ?? []);

final text = parts
    .map((p) => (p is Map<String, dynamic>) ? (p['text']?.toString() ?? '') : '')
    .join()
    .trim();

if (text.length < 200) {
  throw Exception('Response too short (${text.length} chars) - incomplete');
}

debugPrint('🧩 Gemini parts: ${parts.length} | Text length: ${text.length}');
  
  //  debugPrint('AI Response: ${text.length} characters');


     // Log API performance
    AnalyticsService.logApiPerformance(
      apiCallType: feature,
      imageSize: imageSizeKB.round(),
      responseLength: text.length,
      processingTime: processingTime,
      feature: feature,
    );

    
    /*
     // CRITICAL: Validate response has minimum length
    if (text.length < 200) { // Minimum 200 chars for valid JSON
      debugPrint('⚠️ Response too short (${text.length} chars) - likely incomplete');
      throw Exception('Incomplete AI response (too short)');
    }
    */

     /*
     // VALIDATE it's actually JSON, not an error message
    if (!_isValidJSONResponse(text)) {

       AnalyticsService.logApiError(
        errorType: 'invalid_json_response',
        statusCode: null,
        errorDetail: 'Response is not valid JSON',
        feature: feature,
      );

      debugPrint('❌ Invalid response - not JSON: ${text.substring(0, 100)}...');
      throw Exception('API returned non-JSON response');
    }*/
    
    

    return text;

     } catch (e) {

       final errorType = e is TimeoutException ? 'timeout' : 'api_call_failed';
    final errorDetail = e.toString();
    
    AnalyticsService.logApiError(
      errorType: errorType,
      statusCode: null,
      errorDetail: errorDetail,
      feature: feature,
    );

    debugPrint('❌ API call failed: $e');
    rethrow;
  }
  }

 
  Future<File> _compressImage(File originalImage) async {
    try {
      final bytes = await originalImage.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(bytes),
        targetWidth: 800,
      );
      
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData != null) {
        final compressedBytes = byteData.buffer.asUint8List();
        final tempFile = File('${originalImage.path}_compressed.png');
        await tempFile.writeAsBytes(compressedBytes);
        return tempFile;
      }
      
      return originalImage;
    } catch (e) {
      return originalImage;
    }
  }

  
  Future<Plant> identifyPlantFromImage(File imageFile) async {

     final startTime = DateTime.now();
    try {
      final compressedImage = await _compressImage(imageFile);
      final imageBytes = await compressedImage.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      
      debugPrint('Identifying plant (${imageBytes.length} bytes)');
      

      final responseText = await _callGeminiAPI(_prompts['identify']!, base64Image, 'identify');
     
         // Parse JSON with analytics
      final parseStartTime = DateTime.now();
      final jsonData = _parseResponseText(responseText);
      final parseTime = DateTime.now().difference(parseStartTime).inMilliseconds;
      


      // Log successful parsing
    AnalyticsService.logJsonParsing(
      rawLength: responseText.length,
      cleanLength: responseText.length,
      parseTime: parseTime,
      success: true,
    );


      // Cleanup
      if (compressedImage.path != imageFile.path) {
        await compressedImage.delete().catchError((e) {});
      }
      

      // Log final result
    debugPrint('📊 Plant identification success: ${jsonData['plantName']}');


      return Plant.fromJson(jsonData);
      
    } catch (e) {
      debugPrint('Identification failed: $e');


     // Log fallback usage
    AnalyticsService.logFallbackUsed(
      fallbackType: 'basic_fallback',
      fallbackReason: e.toString(),
      feature: 'identify',
    );

      // Provide helpful fallback
      return Plant.fromJson({
        'plantName': 'Plant Recognition Failed',
        'scientificName': 'Try Again',
        'description': 'Please ensure plant is clearly visible. Try focusing on leaves in good lighting.',
        'temperature': '18-25°C typical',
        'light': 'Bright indirect light',
        'soil': 'Well-draining mix',
        'humidity': '40-60%',
        'watering': 'When top soil is dry',
        'fertilizing': 'Balanced fertilizer',
        'toxicity': 'Unknown - use caution'
      });
    }
  }

  Future<Diagnosis> diagnosePlantFromImage(File imageFile) async {

  final compressedImage = await _compressImage(imageFile);
  final imageBytes = await compressedImage.readAsBytes();
  final base64Image = base64Encode(imageBytes);

     int attempt = 0;
  const maxAttempts = 3;
  

  while (attempt < maxAttempts) {

    try {
    //  final compressedImage = await _compressImage(imageFile);
    //  final imageBytes = await compressedImage.readAsBytes();
    //  final base64Image = base64Encode(imageBytes);
      
      final responseText = await _callGeminiAPIWithRetry(
      _prompts['diagnose']!, base64Image, 'diagnose',
      attempt
        );

       // Parse JSON with analytics
      final parseStartTime = DateTime.now();
      final jsonData = _parseResponseText(responseText);
      final parseTime = DateTime.now().difference(parseStartTime).inMilliseconds;


        AnalyticsService.logJsonParsing(
        rawLength: responseText.length,
        cleanLength: responseText.length,
        parseTime: parseTime,
        success: true,
      );



      // Cleanup
      if (compressedImage.path != imageFile.path) {
        await compressedImage.delete().catchError((e) {});
      }
      debugPrint('📊 Diagnosis success: ${jsonData['plantName']}, ${jsonData['severityLevel']}');

  //    // Validate response has minimum required fields
  //    if (jsonData['plantName'] == null || jsonData['severityLevel'] == null) {
  //      throw Exception('Incomplete AI response');
  //    }

      
      return Diagnosis.fromJson(jsonData);
      
    } catch (e) {
       attempt++;

         if (attempt >= maxAttempts) {
       debugPrint('❌ All $maxAttempts attempts failed');

        // Log final failure
        AnalyticsService.logApiError(
          errorType: 'max_retries_exceeded',
          statusCode: null,
          errorDetail: 'Failed after $maxAttempts attempts',
          feature: 'diagnose',
        );



        // Log fallback usage
        AnalyticsService.logFallbackUsed(
          fallbackType: 'service_unavailable_fallback',
          fallbackReason: 'All retries failed',
          feature: 'diagnose',
        );

      
       // Return special fallback 
      return Diagnosis.fromJson({
        'plantName': 'Service Temporarily Unavailable',
        'diseaseName': 'Please Try Again',
        'severityLevel': 'Unknown',
        'symptoms':  'Please wait 30 seconds and retry',
        'immediateActions': 'Wait 30 seconds and try again',
        'treatmentPlan': 'Service will restore automatically',
        'dailyMonitoring': 'Check app status in Settings',
        'expectedRecovery': 'Service typically restores within 60 seconds'
      });
    }
     

       // Log retry attempt
      AnalyticsService.logApiRetry(
        attemptNumber: attempt,
        retryReason: e.toString(),
        feature: 'diagnose',
      );


      // Exponential backoff: 2, 4, 8 seconds
      final delay = Duration(seconds: 2 * attempt);
      debugPrint('⏳ Attempt $attempt/$maxAttempts failed. Waiting ${delay.inSeconds}s...');
      await Future.delayed(delay);
    }
  }
  
  throw Exception('Max retries exceeded');
}

// NEW: Separate method for retry logic
Future<String> _callGeminiAPIWithRetry(String prompt, String base64Image, String feature, int attempt) async {
  try {
    return await _callGeminiAPI(prompt, base64Image, feature);
  } catch (e) {
    if (e.toString().contains('quota') || e.toString().contains('limit')) {
      // Wait longer for quota issues
      await Future.delayed(Duration(seconds: 5 * (attempt + 1)));
    }
    rethrow;
  }
}


Map<String, dynamic> _parseResponseText(String text) {
  debugPrint('🔍 RAW RESPONSE (${text.length} chars)');

   final parseStartTime = DateTime.now();
  
  try {
    // Clean the text first
    String cleanText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    
    // Find JSON start
    int start = cleanText.indexOf('{');
    if (start == -1) {
      debugPrint('❌ No JSON object found');


     AnalyticsService.logJsonParsing(
        rawLength: text.length,
        cleanLength: cleanText.length,
        parseTime: DateTime.now().difference(parseStartTime).inMilliseconds,
        success: false,
        errorDetail: 'No JSON object found',
      );

      return _createBasicFallback();
    }
    
    // Extract potential JSON
    String jsonString = cleanText.substring(start);
    
    // FIX 1: Ensure proper closing brace
    if (!jsonString.trim().endsWith('}')) {
      jsonString = jsonString.trim();
      
      // Find last closing brace
      int lastBrace = jsonString.lastIndexOf('}');
      if (lastBrace != -1) {
        jsonString = jsonString.substring(0, lastBrace + 1);
      } else {
        // No closing brace at all - add one
        jsonString += '}';
      }
    }
    
    // FIX 2: Fix unterminated strings
    jsonString = _fixUnterminatedStrings(jsonString);
    
    // FIX 3: Fix extra commas before closing braces
    jsonString = _fixExtraCommas(jsonString);
    
    // FIX 4: Fix missing quotes
    jsonString = _fixMissingQuotes(jsonString);
    
    debugPrint('🔧 Fixed JSON (${jsonString.length} chars)');


   // Try to parse
    final result = jsonDecode(jsonString);
    final parseTime = DateTime.now().difference(parseStartTime).inMilliseconds;

    
     // Log successful parsing
    AnalyticsService.logJsonParsing(
      rawLength: text.length,
      cleanLength: cleanText.length,
      parseTime: parseTime,
      success: true,
    );

     return result;
    
  } catch (e) {
    final parseTime = DateTime.now().difference(parseStartTime).inMilliseconds;
    
    AnalyticsService.logJsonParsing(
      rawLength: text.length,
      cleanLength: text.length,
      parseTime: parseTime,
      success: false,
      errorDetail: e.toString(),
    );

    debugPrint('❌ JSON parse error after fixes: $e');
    return _createBasicFallback();
  }
}

/*
    // Try to parse
    return jsonDecode(jsonString);
    
  } catch (e) {
    debugPrint('❌ JSON parse error after fixes: $e');
    return _createBasicFallback();
  }
}
*/


// Helper method to fix unterminated strings
String _fixUnterminatedStrings(String jsonString) {
  // Count quotes in each line
  List<String> lines = jsonString.split('\n');
  List<String> fixedLines = [];
  
  for (String line in lines) {
    int quoteCount = line.split('"').length - 1;
    
    // If odd number of quotes, line has unterminated string
    if (quoteCount % 2 == 1) {
      // Add closing quote at end of line
      if (!line.trim().endsWith('"')) {
        line = line.trim() + '"';
      }
    }
    
    fixedLines.add(line);
  }
  
  return fixedLines.join('\n');
}

// Helper method to fix extra commas before closing braces
String _fixExtraCommas(String jsonString) {
  // Fix: "value",} -> "value"}
  return jsonString
      .replaceAllMapped(RegExp(r',\s*}'), (match) => '}')
      .replaceAllMapped(RegExp(r',\s*]'), (match) => ']');
}

// Helper method to fix missing quotes
String _fixMissingQuotes(String jsonString) {
  // Fix: key: value} -> "key": "value"}
  return jsonString
      .replaceAllMapped(RegExp(r'(\s*)(\w+)(\s*):(\s*)([^",\{\[\s][^,}\]\s]*)'), 
        (match) => '${match[1]}"${match[2]}"${match[3]}:${match[4]}"${match[5]}"');
}


  Map<String, dynamic> _createBasicFallback() {
    return {
      'plantName': 'Plant Recognition Needed',
      'scientificName': 'Unknown Species',
      'description': 'Unable to identify from provided image.',
      'temperature': 'Varies by plant type',
      'light': 'Moderate light recommended',
      'soil': 'Well-draining soil',
      'humidity': 'Average humidity',
      'watering': 'Water when soil is dry',
      'fertilizing': 'General plant fertilizer',
      'toxicity': 'Safety unknown - be cautious'
    };
  }

 /* Map<String, dynamic> _parseWaterResponseText(String text) {
  print('Parsing water response: ${text.length} chars');
  

    final parseStartTime = DateTime.now();

  try {
    String cleanText = text.trim();
    
    // Debug: Print first 200 chars to see what we received
    print('Response preview: ${text.substring(0, text.length < 200 ? text.length : 200)}...');
    


    // Remove code blocks if present
    cleanText = cleanText.replaceAll('```json', '').replaceAll('```', '').trim();
    
    // Find JSON object
    final start = cleanText.indexOf('{');
    final end = cleanText.lastIndexOf('}');
    
    if (start != -1 && end != -1 && end > start) {
      cleanText = cleanText.substring(start, end + 1);
      print('Extracted JSON: $cleanText');
    } else {
      print('No JSON object found in response');

    AnalyticsService.logJsonParsing(
        rawLength: text.length,
        cleanLength: cleanText.length,
        parseTime: DateTime.now().difference(parseStartTime).inMilliseconds,
        success: false,
        errorDetail: 'No JSON object found',
      );

      throw Exception('No JSON object in response');
    }
    
    final jsonData = jsonDecode(cleanText);
    final parseTime = DateTime.now().difference(parseStartTime).inMilliseconds;

     // Log successful parsing
    AnalyticsService.logJsonParsing(
      rawLength: text.length,
      cleanLength: cleanText.length,
      parseTime: parseTime,
      success: true,
    );


    print('Successfully parsed water JSON');
    
    // Validate required fields
    if (jsonData['plantName'] == null || jsonData['waterAmount'] == null) {
      print('Missing required fields in water response');
      throw Exception('Incomplete water response');
    }
    
    return jsonData;
    
  } catch (e) {

     final parseTime = DateTime.now().difference(parseStartTime).inMilliseconds;
    
    AnalyticsService.logJsonParsing(
      rawLength: text.length,
      cleanLength: text.length,
      parseTime: parseTime,
      success: false,
      errorDetail: e.toString(),
    );

    
    print('Water JSON parsing failed: $e');
    print('Response that failed: $text');
    rethrow; // Let the main method handle the fallback
  }
}*/

  
  /*Map<String, dynamic> _createWaterFallback() {
    return {
      'plantName': 'Your Plant',
      'waterAmount': '250-300 ML',
      'explanation': 'Standard watering amount for typical houseplants.',
      'frequency': 'Every 5-7 days',
      'bestTime': 'Morning',
      'tips': [
        'Check soil moisture before watering',
        'Water until it drains from bottom',
        'Adjust based on season',
        'Use room temperature water'
      ]
    };
  }*/


// --------------  Water ---------------
 
 Future<WaterCalculation> calculateWaterNeeds({
    required File plantImage,
    required String location,
    required String temperature,
    required String wateringFrequency,
  }) async {
    return _calculateWaterNeedsInternal(
      plantImage: plantImage,
      location: location,
      temperature: temperature,
      wateringFrequency: wateringFrequency,
    );
  }

   Future<WaterCalculation> _calculateWaterNeedsInternal({
    required File plantImage,
    required String location,
    required String temperature,
    required String wateringFrequency,
  }) async {
    final compressed = await _compressImage(plantImage);
    final bytes = await compressed.readAsBytes();
    final base64Image = base64Encode(bytes);

    final prompt = GeminiService._prompts['water']!
        .replaceAll('{location}', location)
        .replaceAll('{temperature}', temperature)
        .replaceAll('{wateringFrequency}', wateringFrequency);

   final responseText = await _callGeminiAPI(
  prompt,
  base64Image,
  'water',
  overrideMaxTokens: 1500, 
);
     //  WATER-ONLY PARSING
final jsonData = _parseWaterJsonSafely(responseText);
   
   // final json = _parseWaterJsonSafely(rawText);

    if (compressed.path != plantImage.path) {
      await compressed.delete().catchError((_) {});
    }

    return WaterCalculation.fromJson(jsonData);
  }


Map<String, dynamic> _parseWaterJsonSafely(String raw) {
  try {
    print('📝 Raw response: $raw');
    
    // Try to extract JSON first
    final RegExp jsonRegex = RegExp(r'\{.*\}', dotAll: true);
    final match = jsonRegex.firstMatch(raw);
    
    if (match != null) {
      String jsonString = match.group(0)!;
      jsonString = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      try {
        final decoded = jsonDecode(jsonString);
        return {
          'plantName': decoded['plantName']?.toString() ?? 'Your Plant',
          'waterAmount': decoded['waterAmount']?.toString() ?? '250-300 ML',
          'explanation': decoded['explanation']?.toString() ?? 'Standard watering recommendation.',
          'frequency': decoded['frequency']?.toString() ?? 'Once a week',
          'bestTime': decoded['bestTime']?.toString() ?? 'Morning',
          'tips': decoded['tips'] is List ? decoded['tips'] : [
            'Check soil moisture before watering',
            'Water until it drains from bottom',
          ],
        };
      } catch (e) {
        print('❌ JSON decode failed: $e');
      }
    }
    
    // If no JSON found or JSON parsing failed, try to parse as plain text
    print('📝 Attempting to parse as plain text');
    
    // Extract plant name (look for common patterns)
    String plantName = 'Your Plant';
    final plantMatch = RegExp(r'plant(?:\s+is)?\s+([^,.]+)', caseSensitive: false).firstMatch(raw);
    if (plantMatch != null) {
      plantName = plantMatch.group(1)!.trim();
    }
    
    // Extract water amount
    String waterAmount = '250-300 ML';
    final amountMatch = RegExp(r'(\d+(?:-\d+)?\s*(?:ml|ML|mL))').firstMatch(raw);
    if (amountMatch != null) {
      waterAmount = amountMatch.group(1)!;
    }
    
    // Extract frequency
    String frequency = 'Once a week';
    if (raw.contains('daily') || raw.contains('Daily')) frequency = 'Daily';
    else if (raw.contains('2-3 days')) frequency = 'Every 2-3 days';
    else if (raw.contains('week')) frequency = 'Once a week';
    else if (raw.contains('biweekly') || raw.contains('two weeks')) frequency = 'Every two weeks';
    
    // Extract best time
    String bestTime = 'Morning';
    if (raw.contains('morning')) bestTime = 'Morning';
    else if (raw.contains('evening')) bestTime = 'Evening';
    else if (raw.contains('afternoon')) bestTime = 'Afternoon';
    
    // Extract explanation (first sentence)
    String explanation = 'Standard watering recommendation for your plant.';
    final sentences = raw.split(RegExp(r'[.!?]'));
    if (sentences.length > 1) {
      explanation = sentences[1].trim();
      if (explanation.isEmpty && sentences.length > 2) {
        explanation = sentences[2].trim();
      }
    }
    
    // Extract tips
    List<String> tips = [
      'Check soil moisture before watering',
      'Water until it drains from bottom',
    ];
    
    final tipLines = raw.split('\n').where((line) => 
      line.contains('•') || line.contains('-') || line.contains('*')
    ).toList();
    
    if (tipLines.isNotEmpty) {
      tips = tipLines.map((line) => 
        line.replaceAll(RegExp(r'^[•\-*\s]+'), '').trim()
      ).where((tip) => tip.isNotEmpty).toList();
    }
    
    return {
      'plantName': plantName,
      'waterAmount': waterAmount,
      'explanation': explanation,
      'frequency': frequency,
      'bestTime': bestTime,
      'tips': tips,
    };
    
  } catch (e) {
    print('❌ Final fallback used: $e');
    return _createWaterFallback();
  }
}
   
// Add this helper method
Map<String, dynamic> _createWaterFallback() {
  return {
    'plantName': 'Your Plant',
    'waterAmount': '250-300 ML',
    'explanation': 'Standard watering recommendation for your plant.',
    'frequency': 'Once a week',
    'bestTime': 'Morning',
    'tips': [
      'Check soil moisture before watering',
      'Water until it drains from bottom',
    ],
  };
}
}



