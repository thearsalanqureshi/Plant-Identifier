import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/history_model.dart';
import '../data/services/analytics_service.dart';
import '../data/services/history_service.dart';
import 'dart:async'; 
import 'dart:developer' as developer;


class HistoryViewModel with ChangeNotifier {
  final HistoryService _historyService = HistoryService();
  
  List<ScanHistory> _allHistory = [];
  List<ScanHistory> _myPlants = [];
  bool _isLoading = false;
  String _error = '';
  bool _showMyPlants = false;
   Timer? _debounceTimer; 
  DateTime? _lastLoadTime; 
  
  List<ScanHistory> get allHistory => _allHistory;
  List<ScanHistory> get myPlants => _myPlants;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get showMyPlants => _showMyPlants;
  int get myPlantsCount => _myPlants.length;
  int get historyCount => _allHistory.length;

  
  /*
  Future<void> loadHistory() async {
    print('📱 [VIEWMODEL] loadHistory() called');
    
    if (_isLoading) {
      print('⏸️ Already loading, skipping');
      return;
    }
    
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      print('🔍 Opening Hive box...');
      final box = await Hive.openBox<ScanHistory>('scanHistory');
      print('📦 Box opened, keys: ${box.keys.length}');

      print('🔍 [HISTORY] Loading from Hive...');

     if (box.keys.isNotEmpty) {
  print('📋 Keys in box: ${box.keys.toList()}');
  for (var key in box.keys) {
    final scan = box.get(key);
    print('   Key: $key → ${scan?.plantName}');
  }
}

      if (box.keys.isEmpty) {
        print('📭 Box is empty');
        _allHistory = [];
        _myPlants = [];
      } else {
        print('🔄 Loading scans from Hive...');
        _allHistory = box.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _myPlants = _allHistory.where((scan) => scan.isSaved).toList();
        
        print('✅ Loaded ${_allHistory.length} scans, ${_myPlants.length} saved');
        for (var scan in _allHistory) {
          print('   - ${scan.plantName} (${scan.timestamp})');
        }
      }
      
      _isLoading = false;
      notifyListeners();
      print('🎯 loadHistory() completed successfully');
      
    } catch (e) {
      print('💥 loadHistory() ERROR: $e');
      _isLoading = false;
      _error = 'Failed to load history';
      notifyListeners();
    }
  }
  */

Future<void> loadHistory({bool forceRefresh = false}) async {
    developer.log('📱 [VIEWMODEL] loadHistory() called', name: 'HISTORY');
    print('📱 [VIEWMODEL] loadHistory() - force: $forceRefresh');
    
    // DEBOUNCE: Prevent rapid consecutive calls (500ms)
    if (_debounceTimer?.isActive ?? false) {
      print('⏸️ Debouncing: Skipping duplicate loadHistory call');
      return;
    }
    
    _debounceTimer = Timer(Duration(milliseconds: 500), () {});
    
    // COOLDOWN: Don't load more than once per second
    if (!forceRefresh && 
        _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!).inSeconds < 1) {
      print('⏸️ Cooldown: Skipping load (last load was <1s ago)');
      return;
    }
    
    if (_isLoading) {
      print('⏸️ Already loading, skipping');
      return;
    }
    
    try {
      _isLoading = true;
      _error = '';
      developer.log('🔄 Loading history started', name: 'HISTORY');
      notifyListeners(); // Only notify ONCE here
      
      print('🔍 Opening Hive box...');
      final box = await Hive.openBox<ScanHistory>('scanHistory');
      print('📦 Box opened, keys: ${box.keys.length}');
      
      if (box.keys.isEmpty) {
        print('📭 Box is empty');
        _allHistory = [];
        _myPlants = [];
      } else {
        print('🔄 Loading scans from Hive...');
        _allHistory = box.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _myPlants = _allHistory.where((scan) => scan.isSaved).toList();
        
        print('✅ Loaded ${_allHistory.length} scans, ${_myPlants.length} saved');
        
        // Log only first 3 items to avoid spam
        final scansToLog = _allHistory.take(3);
        for (var scan in scansToLog) {
          print('   - ${scan.plantName} (${scan.timestamp})');
        }
        if (_allHistory.length > 3) {
          print('   ... and ${_allHistory.length - 3} more');
        }
      }
      
      _isLoading = false;
      _lastLoadTime = DateTime.now(); // Update last load time
      developer.log('✅ History loaded successfully', name: 'HISTORY');
      notifyListeners(); // Final notify after data is ready
      print('🎯 loadHistory() completed successfully');
      
    } catch (e) {
      print('💥 loadHistory() ERROR: $e');
      _isLoading = false;
      _error = 'Failed to load history';
      developer.log('❌ History load failed: $e', name: 'HISTORY');
      notifyListeners();
    }
  }


  void toggleView(bool showMyPlants) {
    print('🔄 Toggling view to: ${showMyPlants ? "My Plants" : "All History"}');
    _showMyPlants = showMyPlants;


   // Log tab changed
  final tabName = showMyPlants ? 'my_plants' : 'all_history';
  AnalyticsService.logTabChanged(tabName: tabName);
  debugPrint('📊 Analytics: Tab changed to "$tabName"');

    notifyListeners();
  }
  
  Future<void> deleteScan(String scanId) async {
    print('🗑️ Deleting scan: $scanId');
    try {
      await _historyService.deleteScan(scanId);
      await loadHistory();
      print('✅ Scan deleted successfully');
    } catch (e) {
      print('❌ Delete error: $e');
      _error = 'Failed to delete scan';
      notifyListeners();
    }
  }
  
  Future<void> toggleSaveStatus(String scanId) async {
    print('💾 Toggling save status for: $scanId');
    try {
      await _historyService.toggleSaveStatus(scanId);
      await loadHistory();
      print('✅ Save status updated');
    } catch (e) {
      print('❌ Save toggle error: $e');
      _error = 'Failed to update save status';
      notifyListeners();
    }
  }

  @override
void dispose() {
  _debounceTimer?.cancel();
  print('🔄 HistoryViewModel disposed');
  super.dispose();
}
}