import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/history_model.dart';
import '../models/history_model_adapter.dart';
import '../models/plant_model_adapter.dart';

class HistoryService {
  static const String historyBox = 'scanHistory';
  static Box<ScanHistory>? _box;

  // Get the box instance (singleton pattern)
  static Future<Box<ScanHistory>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<ScanHistory>(historyBox);
    }
    return _box!;
  }

  Future<void> saveScan(ScanHistory scan) async {
    try {
      final box = await _getBox();
      await box.put(scan.id, scan);
      // Flush to ensure disk write
      await box.flush();
      debugPrint(' Scan saved: ${scan.plantName}');
    } catch (e) {
      debugPrint(' Save error: $e');
      rethrow;
    }
  }

  Future<List<ScanHistory>> getScanHistory() async {
    try {
      final box = await _getBox();
      final scans = box.values.toList();
      scans.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      debugPrint(' Loaded ${scans.length} scans');
      return scans;
    } catch (e) {
      debugPrint(' Get history error: $e');
      return [];
    }
  }

  Future<List<ScanHistory>> getMyPlants() async {
    try {
      final box = await _getBox();
      final myPlants = box.values
          .where((scan) => scan.isSaved)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return myPlants;
    } catch (e) {
      debugPrint('My Plants load error: $e');
      return [];
    }
  }

  Future<void> deleteScan(String scanId) async {
    final box = await _getBox();
    await box.delete(scanId);
    await box.flush();
  }

  Future<void> toggleSaveStatus(String scanId) async {
    final box = await _getBox();
    final scan = box.get(scanId);
    if (scan != null) {
      final updatedScan = scan.copyWith(isSaved: !scan.isSaved);
      await box.put(scanId, updatedScan);
      await box.flush();
    }
  }

  // Call when app closes
  /*
  static Future<void> closeBox() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
  */
}