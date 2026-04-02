import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../app/navigation/navigation_service.dart';
import '../data/models/diagnosis_model.dart';
import '../data/models/history_model.dart';
import '../data/services/analytics_service.dart';
import '../data/services/gemini_service.dart';
import '../data/services/history_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/translation_service.dart';

class DiagnosisViewModel with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();
  
  Diagnosis? _diagnosis;
  bool _isLoading = true;
  String _error = '';
  File? _imageFile;

  Diagnosis? get diagnosis => _diagnosis;
  bool get isLoading => _isLoading;
  String get error => _error;
  File? get imageFile => _imageFile;

  void _safeNotifyListeners() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (hasListeners) {
      notifyListeners();
    }
  });
}

  void setImageFile(File imageFile) {
    _imageFile = imageFile;
    _safeNotifyListeners();
  }

  Future<void> diagnosePlant(File imageFile) async {
 final startTime = DateTime.now(); // Track processing time

    try {
       // Only prevent if SAME image is being processed AND we're not loading from history
     if (_isLoading && _imageFile?.path == imageFile.path && _diagnosis == null) {
      debugPrint('⚠️ Same image already processing - skipping');
      return;
    }

      _isLoading = true;
      _error = '';
       _imageFile = imageFile; // IMPORTANT: Set image file before notify
      _safeNotifyListeners();


      // ACTUAL API CALL MUST HAPPEN HERE
    debugPrint('🔧 Starting Gemini API call for diagnosis');
      final diagnosisResult = await _geminiService.diagnosePlantFromImage(imageFile);
      _diagnosis = diagnosisResult;

    
    // 🔥 ADD THIS - Translate if not English
    final locale = Localizations.localeOf(NavigationService.navigatorKey.currentContext!).languageCode;
    if (locale != 'en') {
      final translatedMap = await TranslationService.translateDiagnosisData(
        diagnosisResult.toMap(), 
        locale
      );
      _diagnosis = Diagnosis.fromJson(translatedMap);
    } else {
      _diagnosis = diagnosisResult;
    }




      // Log processing success
    final processingTime = DateTime.now().difference(startTime).inMilliseconds;
    AnalyticsService.logProcessingComplete(
      mode: 'diagnose',
      success: true,
      processingTime: processingTime,
    );
    debugPrint('📊 Analytics: Diagnosis processing logged');



      
      _isLoading = false;
     _safeNotifyListeners();

   //   await _saveToScanHistory();
    await _saveToScanHistory(imageFile, diagnosisResult);

    } catch (e) {

       // Log processing failure
    AnalyticsService.logProcessingComplete(
      mode: 'diagnose',
      success: false,
      error: e.toString(),
    );

    
      _isLoading = false;
      _error = 'Failed to diagnose plant: $e';
      _safeNotifyListeners();
      debugPrint('Plant diagnosis error: $e');
    }
  }

  void reset() {
    _diagnosis = null;
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();
  }

  // SINGLE METHOD 
Future<void> _saveToScanHistory(File imageFile, Diagnosis diagnosis) async { 
    try {
      final historyService = HistoryService();
      
      
      final allScans = await historyService.getScanHistory();
      final now = DateTime.now();
      
      
      ScanHistory? similarRecentScan;
      try {
        similarRecentScan = allScans.firstWhere(
          (scan) => 
            scan.plantName.toLowerCase() == diagnosis.plantName.toLowerCase() &&
            scan.type == 'diagnose' &&
            now.difference(scan.timestamp).inHours < 1,
        );
      } catch (e) {
       
        similarRecentScan = null;
      }
      
   
      if (similarRecentScan != null) {
        debugPrint('Duplicate diagnosis detected for ${_diagnosis!.plantName} - not saving');
        return;
      }
      
      
      final scan = ScanHistory(
        id: 'diagnose_${DateTime.now().millisecondsSinceEpoch}',
        type: 'diagnose',
        plantName: diagnosis.plantName,
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        isSaved: false,
        hasAbnormality: diagnosis.severityLevel != 'Healthy',
        resultData: diagnosis.toMap(),
      );
      
      await historyService.saveScan(scan);
      debugPrint('Diagnosis scan saved to history: ${_diagnosis!.plantName}');
      
    } catch (e) {
      debugPrint('Error saving diagnosis to scan history: $e');
    }
  }
 
void loadFromHistory(Map<String, dynamic> scanData, String? imagePath) {
  try {
    // Reset state
    _diagnosis = null;
    _isLoading = false;
    _error = '';
    
    // Load diagnosis data
    _diagnosis = Diagnosis.fromJson(scanData);
    
    // Load image if path exists
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        _imageFile = file;
      }
    }

      // Log result viewed
    AnalyticsService.logResultViewed(
      resultType: 'diagnosis',
      mode: 'diagnose',
    );
    debugPrint('📊 Analytics: Diagnosis result viewed logged');

    
     // Log diagnosis viewed with details
    if (_diagnosis != null) {
      AnalyticsService.logDiagnosisViewed(
        plantName: _diagnosis!.plantName,
        diseaseName: _diagnosis!.diseaseName,
        severity: _diagnosis!.severityLevel,
      );
      debugPrint('📊 Analytics: Diagnosis viewed - ${_diagnosis!.plantName}, ${_diagnosis!.diseaseName}');
    }

    _safeNotifyListeners();
  } catch (e) {
    _error = 'Failed to load diagnosis data: $e';
    _safeNotifyListeners();
  }
}
}

/*// ------- Original -------
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../data/models/diagnosis_model.dart';
import '../data/models/history_model.dart';
import '../data/services/analytics_service.dart';
import '../data/services/gemini_service.dart';
import '../data/services/history_service.dart';
import '../data/services/storage_service.dart';

class DiagnosisViewModel with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();
  
  Diagnosis? _diagnosis;
  bool _isLoading = true;
  String _error = '';
  File? _imageFile;

  Diagnosis? get diagnosis => _diagnosis;
  bool get isLoading => _isLoading;
  String get error => _error;
  File? get imageFile => _imageFile;

  void _safeNotifyListeners() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (hasListeners) {
      notifyListeners();
    }
  });
}

  void setImageFile(File imageFile) {
    _imageFile = imageFile;
    _safeNotifyListeners();
  }

  Future<void> diagnosePlant(File imageFile) async {
 final startTime = DateTime.now(); // Track processing time

    try {
       // Only prevent if SAME image is being processed AND we're not loading from history
     if (_isLoading && _imageFile?.path == imageFile.path && _diagnosis == null) {
      debugPrint('⚠️ Same image already processing - skipping');
      return;
    }

      _isLoading = true;
      _error = '';
       _imageFile = imageFile; // IMPORTANT: Set image file before notify
      _safeNotifyListeners();


      // ACTUAL API CALL MUST HAPPEN HERE
    debugPrint('🔧 Starting Gemini API call for diagnosis');
      final diagnosisResult = await _geminiService.diagnosePlantFromImage(imageFile);
      _diagnosis = diagnosisResult;



      // Log processing success
    final processingTime = DateTime.now().difference(startTime).inMilliseconds;
    AnalyticsService.logProcessingComplete(
      mode: 'diagnose',
      success: true,
      processingTime: processingTime,
    );
    debugPrint('📊 Analytics: Diagnosis processing logged');



      
      _isLoading = false;
     _safeNotifyListeners();

   //   await _saveToScanHistory();
    await _saveToScanHistory(imageFile, diagnosisResult);

    } catch (e) {

       // Log processing failure
    AnalyticsService.logProcessingComplete(
      mode: 'diagnose',
      success: false,
      error: e.toString(),
    );

    
      _isLoading = false;
      _error = 'Failed to diagnose plant: $e';
      _safeNotifyListeners();
      debugPrint('Plant diagnosis error: $e');
    }
  }

  void reset() {
    _diagnosis = null;
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();
  }

  // SINGLE METHOD 
Future<void> _saveToScanHistory(File imageFile, Diagnosis diagnosis) async { 
    try {
      final historyService = HistoryService();
      
      
      final allScans = await historyService.getScanHistory();
      final now = DateTime.now();
      
      
      ScanHistory? similarRecentScan;
      try {
        similarRecentScan = allScans.firstWhere(
          (scan) => 
            scan.plantName.toLowerCase() == diagnosis.plantName.toLowerCase() &&
            scan.type == 'diagnose' &&
            now.difference(scan.timestamp).inHours < 1,
        );
      } catch (e) {
       
        similarRecentScan = null;
      }
      
   
      if (similarRecentScan != null) {
        debugPrint('Duplicate diagnosis detected for ${_diagnosis!.plantName} - not saving');
        return;
      }
      
      
      final scan = ScanHistory(
        id: 'diagnose_${DateTime.now().millisecondsSinceEpoch}',
        type: 'diagnose',
        plantName: diagnosis.plantName,
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        isSaved: false,
        hasAbnormality: diagnosis.severityLevel != 'Healthy',
        resultData: diagnosis.toMap(),
      );
      
      await historyService.saveScan(scan);
      debugPrint('Diagnosis scan saved to history: ${_diagnosis!.plantName}');
      
    } catch (e) {
      debugPrint('Error saving diagnosis to scan history: $e');
    }
  }
 
void loadFromHistory(Map<String, dynamic> scanData, String? imagePath) {
  try {
    // Reset state
    _diagnosis = null;
    _isLoading = false;
    _error = '';
    
    // Load diagnosis data
    _diagnosis = Diagnosis.fromJson(scanData);
    
    // Load image if path exists
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        _imageFile = file;
      }
    }

      // Log result viewed
    AnalyticsService.logResultViewed(
      resultType: 'diagnosis',
      mode: 'diagnose',
    );
    debugPrint('📊 Analytics: Diagnosis result viewed logged');

    
     // Log diagnosis viewed with details
    if (_diagnosis != null) {
      AnalyticsService.logDiagnosisViewed(
        plantName: _diagnosis!.plantName,
        diseaseName: _diagnosis!.diseaseName,
        severity: _diagnosis!.severityLevel,
      );
      debugPrint('📊 Analytics: Diagnosis viewed - ${_diagnosis!.plantName}, ${_diagnosis!.diseaseName}');
    }

    _safeNotifyListeners();
  } catch (e) {
    _error = 'Failed to load diagnosis data: $e';
    _safeNotifyListeners();
  }
}
}*/