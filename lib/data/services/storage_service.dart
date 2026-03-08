// storage_service.dart - UPDATE with singleton
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/plant_model.dart';

class StorageService {
  static const String plantsBox = 'plants';
  static Box<Plant>? _box;

  // Singleton
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<Box<Plant>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Plant>(plantsBox);
    return _box!;
  }

  Future<bool> isPlantSaved(String plantName) async {
    try {
      final box = await _getBox();
      return box.containsKey(plantName);
    } catch (e) {
      debugPrint(' Storage check error: $e');
      return false;
    }
  }

  Future<List<Plant>> getSavedPlants() async {
    try {
      final box = await _getBox();
      return box.values.toList();
    } catch (e) {
      debugPrint(' Get saved plants error: $e');
      return [];
    }
  }
  
  Future<void> savePlant(Plant plant) async {
    try {
      final box = await _getBox();
      await box.put(plant.plantName, plant);
      await box.flush(); // Force disk write
      debugPrint(' Plant saved to Hive: ${plant.plantName}');
    } catch (e) {
      debugPrint(' Save plant error: $e');
    }
  }
  
  Future<void> removePlant(String plantName) async {
    try {
      final box = await _getBox();
      await box.delete(plantName);
      await box.flush(); // Force disk write
      debugPrint(' Plant removed from Hive: $plantName');
    } catch (e) {
      debugPrint(' Remove plant error: $e');
    }
  }

  static Future<void> closeBox() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}