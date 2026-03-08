import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../app/navigation/navigation_service.dart';
import '../data/models/history_model.dart';
import '../data/models/water_calculation_model.dart';
import '../data/services/analytics_service.dart';
import '../data/services/gemini_service.dart';
import '../data/services/history_service.dart';
import '../data/services/translation_service.dart';
import '../../../app/navigation/navigation_service.dart';


class WaterCalculationViewModel with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  
  File? _imageFile;
  String _location = '';
  String _temperature = '';
  String _wateringFrequency = '';
  bool _isLoading = false;
  String _error = '';
  WaterCalculation? _waterCalculation;
  int _currentQuestion = 1;

  // Getters
  File? get imageFile => _imageFile;
  bool get isLoading => _isLoading;
  String get error => _error;
  WaterCalculation? get waterCalculation => _waterCalculation;
  int get currentQuestion => _currentQuestion;
  String get location => _location;
  String get temperature => _temperature;
  String get wateringFrequency => _wateringFrequency;


  // Setters
  void setImageFile(File imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }

  void setLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void setTemperature(String temperature) {
    _temperature = temperature;
    notifyListeners();
  }

  void setWateringFrequency(String frequency) {
    _wateringFrequency = frequency;
    notifyListeners();
  }

  void setCurrentQuestion(int question) {
    if (_currentQuestion != question) {
       _currentQuestion = question;
      
    notifyListeners();
     };
  }

Future<void> processWaterCalculation({
  required File plantImage,
  required String location,
  required String temperature,
  required String wateringFrequency,
}) async {

  await calculateWaterNeedsWithGemini(
    plantImage: plantImage,
    location: location,
    temperature: temperature,
    wateringFrequency: wateringFrequency,
  );
}

  // Gemini API method
  Future<void> calculateWaterNeedsWithGemini({
  required File plantImage,
  required String location,
  required String temperature,
  required String wateringFrequency,
}) async {

   print('VIEWMODEL: STARTING GEMINI API CALL');
  final startTime = DateTime.now(); // Track processing time

  print('VIEWMODEL: STARTING GEMINI API CALL');
  print('Location: $location');
  print('Temperature: $temperature');
  print('Watering Frequency: $wateringFrequency');
  print('Image: ${plantImage.path}');
  
  
   int attempt = 0;
  const maxAttempts = 3;


  try {
    _isLoading = true;
    _error = '';
    _waterCalculation = null;
    _imageFile = plantImage; // CRITICAL: Set image file
    notifyListeners();


     while (attempt < maxAttempts) {
      try {
        print('📊 Attempt ${attempt + 1}/$maxAttempts');

        print('CALLING GEMINI SERVICE...');


    
    // Call Gemini API for dynamic water calculation
    _waterCalculation = await _geminiService.calculateWaterNeeds(
      plantImage: plantImage,
      location: location,
      temperature: temperature,
      wateringFrequency: wateringFrequency,
    );

      // If we get here, success!
        break;
        
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow; // All attempts failed
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    // Only translate if we have valid data
    if (_waterCalculation != null) {


final locale = Localizations.localeOf(
  NavigationService.navigatorKey.currentContext!).languageCode;
   
    if (locale != 'en') {
    
  // Translate individual fields only
  _waterCalculation = WaterCalculation(
    plantName: await TranslationService.translateText(
      _waterCalculation!.plantName, locale),
    
    waterAmount: _waterCalculation!.waterAmount, // Keep numbers as-is
    explanation: await TranslationService.translateText(
      _waterCalculation!.explanation, locale),
    frequency: await TranslationService.translateText(
      _waterCalculation!.frequency, locale),
    bestTime: await TranslationService.translateText(
      _waterCalculation!.bestTime, locale),
    tips: await Future.wait(_waterCalculation!.tips.map((tip) => 
      TranslationService.translateText(tip, locale)
    )),
        );
      }
    }

     // Log processing success
    final processingTime = DateTime.now().difference(startTime).inMilliseconds;
    AnalyticsService.logProcessingComplete(
      mode: 'water',
      success: true,
      processingTime: processingTime,
    );
    
    _isLoading = false;
    _error = '';
    notifyListeners();

    
    // Save to history after successful calculation
    await _saveToScanHistory();
    
  } catch (e) {


    // Log processing failure
    AnalyticsService.logProcessingComplete(
      mode: 'water',
      success: false,
      error: e.toString(),
    );
    


    print('VIEWMODEL: GEMINI API ERROR: $e');
    _isLoading = false;
    _error = 'Failed to calculate water needs: $e';
    _waterCalculation = null;
    notifyListeners();
    
    debugPrint('Water calculation API error: $e');
  }
}


// ADD getter for result type logging
String get resultType => 'water';


  bool get canProceedToNextQuestion {
    switch (_currentQuestion) {
      case 1:

        return _location.isNotEmpty;
      case 2:
        return _temperature.isNotEmpty;
      case 3:
        return _wateringFrequency.isNotEmpty;
      default:
        return false;
    }
  }

  void reset() {
    _imageFile = null;
    _location = '';
    _temperature = '';
    _wateringFrequency = '';
    _waterCalculation = null;
    _currentQuestion = 1;
    _error = '';
    _isLoading = false;
    notifyListeners();
  }


Future<void> _saveToScanHistory() async {
  try {
    if (_waterCalculation == null || _imageFile == null) return;
    
    final historyService = HistoryService();
    
    final scan = ScanHistory(
      id: 'water_${DateTime.now().millisecondsSinceEpoch}',
      type: 'water',
      plantName: _waterCalculation!.plantName,
      timestamp: DateTime.now(),
      imagePath: _imageFile!.path,
      isSaved: false,
      hasAbnormality: false,
      resultData: _waterCalculation!.toMap(),
    );
    
    await historyService.saveScan(scan);
    debugPrint('Water calculation saved to history: ${_waterCalculation!.plantName}');
    
  } catch (e) {
    debugPrint('Error saving water calculation to history: $e');
  }
}


Future<void> loadFromHistory(Map<String, dynamic> scanData, String? imagePath) async {
  print('📚 [WATER] Loading from history');
  try {
    // Reset state
    _isLoading = false;
    _error = '';
    _waterCalculation = null;
    
    // Load water calculation data from scan history
    _waterCalculation = WaterCalculation.fromJson(scanData);
    
    // Load image if path exists
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        _imageFile = file;
      }
    }
    
    // Log result viewed
    AnalyticsService.logResultViewed(
      resultType: 'water',
      mode: 'water',
    );
    print('📊 [WATER] Analytics: Result viewed logged');
    
    // Log water calculation viewed
    if (_waterCalculation != null) {
      AnalyticsService.logWaterCalculated(
        plantName: _waterCalculation!.plantName,
        waterAmount: _waterCalculation!.waterAmount,
      );
      print('📊 Analytics: Water calculation viewed - ${_waterCalculation!.plantName}: ${_waterCalculation!.waterAmount}');
    }
    
    notifyListeners();
    print('✅ [WATER] Loaded from history: ${_waterCalculation?.plantName}');
  } catch (e) {
    _isLoading = false;
    _error = 'Failed to load water calculation data: $e';
    print('❌ [WATER] Load from history error: $e');
    notifyListeners();
  }
}
}