import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import '../app/navigation/navigation_service.dart';
import '../data/models/history_model.dart';
import '../data/models/plant_model.dart';
import '../../data/services/gemini_service.dart'; 
import '../data/services/analytics_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/history_service.dart';
import '../data/services/translation_service.dart';

class PlantResultViewModel with ChangeNotifier {
  final GeminiService _geminiService = GeminiService(); 
  final StorageService _storageService = StorageService();
  
  Plant? _plant;
  bool _isLoading = true;
  String _error = '';
  File? _imageFile;
  bool _isSaved = false;

  Plant? get plant => _plant;
  bool get isLoading => _isLoading;
  String get error => _error;
  File? get imageFile => _imageFile;
  bool get isSaved => _isSaved;

  void setImageFile(File imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }

  void _safeNotifyListeners() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (hasListeners) {
      notifyListeners();
    }
  });
}

  Future<void> identifyPlant(File imageFile, {String? scanId}) async {
    developer.log('🌿 IDENTIFY PLANT START', name: 'PERSISTENCE');
    print('🎯 [PLANT] Starting identification');
    
     final startTime = DateTime.now(); // Track processing time

    try {
      _isLoading = true;
      _error = '';
      _imageFile = imageFile;
       _safeNotifyListeners();


       // Add small delay to ensure UI is stable
    await Future.delayed(Duration(milliseconds: 100));

      // Use provided scanId OR generate new
      final finalScanId = scanId ?? 'scan_${DateTime.now().millisecondsSinceEpoch}';
      print('📝 [PLANT] Scan ID: $finalScanId');
      
      //  SAVE PLACEHOLDER 
      final box = await Hive.openBox<ScanHistory>('scanHistory');
      await box.put(finalScanId, ScanHistory(
        id: finalScanId,
        type: 'identify',
        plantName: 'Identifying...',
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        isSaved: false,
        hasAbnormality: false,
        resultData: {'status': 'processing'},
      ));
     
     
      await box.flush();
      print('📦 [PLANT] Placeholder saved, keys: ${box.keys.length}');
      

      // Call Gemini API
      print('🤖 [PLANT] Calling Gemini API...');
      final identifiedPlant = await _geminiService.identifyPlantFromImage(imageFile);
     
     // 🔥 ADD THIS - Translate if not English
    final locale = Localizations.localeOf(NavigationService.navigatorKey.currentContext!).languageCode;
    if (locale != 'en') {
      final translatedMap = await TranslationService.translatePlantData(
        identifiedPlant.toJson(),
        locale
      );
      _plant = Plant.fromJson(translatedMap);
    } else {
      _plant = identifiedPlant;
    }
      
      if (_plant != null) {
        print('✅ [PLANT] Identified: ${_plant!.plantName}');
        


       // Log plant identification
      AnalyticsService.logPlantIdentified(
        plantName: _plant!.plantName,
      );
      print('📊 Analytics: Plant "${_plant!.plantName}" identified');



        // Check if saved
        _isSaved = await _storageService.isPlantSaved(_plant!.plantName);
        print('💾 [PLANT] Save status: $_isSaved');
        
        // UPDATE placeholder with real data
        await _updateHiveScanWithRealData(finalScanId);
        
        developer.log('✅ PLANT SAVE COMPLETE', name: 'PERSISTENCE');
        print('🎉 [PLANT] Scan saved to history successfully');
      } else {
        print('❌ [PLANT] Identification returned null');
      }
      
      _isLoading = false;
       _safeNotifyListeners();
      


     // Log processing success
    final processingTime = DateTime.now().difference(startTime).inMilliseconds;
    AnalyticsService.logProcessingComplete(
      mode: 'identify',
      success: true,
      processingTime: processingTime,
    );
    
    print('✅ [PLANT] Analytics: Processing logged successfully');



    } catch (e) {

      // Log processing failure
    AnalyticsService.logProcessingComplete(
      mode: 'identify',
      success: false,
      error: e.toString(),
    );


      developer.log('💥 PLANT IDENTIFICATION ERROR', 
                    name: 'PERSISTENCE', 
                    error: e);
      print('💥 [PLANT] Error: $e');
      _isLoading = false;
      _error = 'Failed to identify plant';
       _safeNotifyListeners();
    }
  }

  Future<void> _updateHiveScanWithRealData(String scanId) async {
    if (_plant == null) return;
    
    developer.log('💾 UPDATING HIVE SCAN', name: 'PERSISTENCE');
    print('🔄 [PERSISTENCE] Updating scan: $scanId');
    
    try {
      final box = await Hive.openBox<ScanHistory>('scanHistory');
      
      // Update placeholder with real plant data
      final updatedScan = ScanHistory(
        id: scanId,
        type: 'identify',
        plantName: _plant!.plantName,
        timestamp: DateTime.now(),
        imagePath: _imageFile?.path ?? '',
        isSaved: _isSaved,
        hasAbnormality: false,
        resultData: _plant!.toJson(),
      );
      
      await box.put(scanId, updatedScan);
      await box.flush();
      
      // VERIFICATION
      final savedScan = box.get(scanId);
      if (savedScan != null) {
        developer.log('✅ SCAN VERIFIED IN HIVE', name: 'PERSISTENCE');
        print('✅✅✅ [PERSISTENCE] VERIFIED:');
        print('   ID: ${savedScan.id}');
        print('   Plant: ${savedScan.plantName}');
        print('   Time: ${savedScan.timestamp}');
        print('   Box keys: ${box.keys.length}');
      } else {
        print('❌❌❌ [PERSISTENCE] VERIFICATION FAILED!');
      }
      
    } catch (e) {
      developer.log('❌ UPDATE SCAN ERROR', 
                    name: 'PERSISTENCE', 
                    error: e);
      print('💥 [PERSISTENCE] Update error: $e');
    }
  }

  Future<void> saveToMyPlants() async {
    if (_plant != null) {
      try {
        await _storageService.savePlant(_plant!);
        _isSaved = true;
         _safeNotifyListeners();
        print('💾 [PLANT] Saved to My Plants: ${_plant!.plantName}');
      } catch (e) {
        print('❌ [PLANT] Save error: $e');
      }
    }
  }

  Future<void> removeFromMyPlants() async {
    if (_plant != null) {
      try {
        await _storageService.removePlant(_plant!.plantName);
        _isSaved = false;
         _safeNotifyListeners();
        print('🗑️ [PLANT] Removed from My Plants: ${_plant!.plantName}');
      
      
       //  Log plant removed
      AnalyticsService.logPlantRemoved(
        plantName: _plant!.plantName,
      );
      print('📊 Analytics: Plant "${_plant!.plantName}" removed');
      
  
      
      } catch (e) {
        print('❌ [PLANT] Remove error: $e');
      }
    }
  }

  Future<void> toggleSaveStatus() async {
    print('🔘 [PLANT] Toggling save status');
    if (_isSaved) {
      await removeFromMyPlants();
    } else {
      await saveToMyPlants();
    }
    
    // Update history when save status changes
    if (_plant != null) {
      await _updateScanHistorySaveStatus();
    }
  }

  Future<void> _updateScanHistorySaveStatus() async {
    try {
      final historyService = HistoryService();
      final allScans = await historyService.getScanHistory();
      
      final plantScans = allScans
          .where((scan) => scan.plantName == _plant!.plantName)
          .toList();
          
      if (plantScans.isNotEmpty) {
        final latestScan = plantScans.first;
        await historyService.toggleSaveStatus(latestScan.id);
        print('📝 [PLANT] Updated save status for: ${_plant!.plantName}');
      }
    } catch (e) {
      print('❌ [PLANT] Update save status error: $e');
    }
  }

  void reset() {
    _plant = null;
    _isLoading = true;
    _error = '';
    _isSaved = false;
    print('🔄 [PLANT] ViewModel reset');
    _safeNotifyListeners();
  }

  Future<void> loadFromHistory(Map<String, dynamic> scanData, String? imagePath) async {
    print('📚 [PLANT] Loading from history');
    try {
      _resetState();
      
      // Load plant data
      _plant = Plant.fromJson(scanData);
      
      // Load image if path exists
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          _imageFile = file;
        }
      }
      
      // Check if plant is saved
      if (_plant != null) {
        _isSaved = await _storageService.isPlantSaved(_plant!.plantName);
      }
      

       // Log result viewed
    AnalyticsService.logResultViewed(
      resultType: 'identification',
      mode: 'identify',
    );
    print('📊 [PLANT] Analytics: Result viewed logged');



      _isLoading = false;
      print('✅ [PLANT] Loaded from history: ${_plant?.plantName}');
       _safeNotifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load plant data: $e';
      print('❌ [PLANT] Load from history error: $e');
       _safeNotifyListeners();
    }
  }


  void _resetState() {
    _plant = null;
    _isLoading = true;
    _error = '';
    _imageFile = null;
  }
}