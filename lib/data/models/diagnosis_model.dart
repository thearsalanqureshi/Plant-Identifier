import 'package:flutter/widgets.dart';

class Diagnosis {
  final String plantName;
  final String diseaseName;
  final String severityLevel;
  final String symptoms;
  final String immediateActions;
  final String treatmentPlan;
  final String dailyMonitoring;
  final String expectedRecovery;

  Diagnosis({
    required this.plantName,
    required this.diseaseName,
    required this.severityLevel,
    required this.symptoms,
    required this.immediateActions,
    required this.treatmentPlan,
    required this.dailyMonitoring,
    required this.expectedRecovery,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {

    // Check if this is a fallback response (indicates JSON parsing failed)
  bool isFallbackResponse = json['plantName']?.toString().contains('Plant Recognition Needed') == true;
  
  // If it's a fallback, don't override severity
  if (isFallbackResponse) {
    return Diagnosis(
      plantName: json['plantName'] ?? 'Plant Recognition Needed',
      diseaseName: json['diseaseName'] ?? 'Unable to Analyze',
      severityLevel: json['severityLevel']?.toString().trim() ?? 'Unknown',
      symptoms: json['symptoms'] ?? 'Image processing failed',
      immediateActions: json['immediateActions'] ?? 'Try with clearer image',
      treatmentPlan: json['treatmentPlan'] ?? 'Consult plant expert',
      dailyMonitoring: json['dailyMonitoring'] ?? 'Monitor plant health',
      expectedRecovery: json['expectedRecovery'] ?? 'Proper diagnosis needed',
    );
  }

  debugPrint('🔄 Diagnosis.fromJson() called');
  debugPrint('🔄 Raw JSON plantName: "${json['plantName']}"');
  debugPrint('🔄 Raw JSON diseaseName: "${json['diseaseName']}"');
  debugPrint('🔄 Raw JSON severityLevel: "${json['severityLevel']}"');
    
    String rawPlantName = json['plantName']?.toString().trim() ?? 'Unknown Plant';
    debugPrint('🔄 Raw plant name: "$rawPlantName"');
    
    String normalizedPlantName = _normalizePlantName(rawPlantName);
     debugPrint('🔄 Normalized plant name: "$normalizedPlantName"');


    final diseaseName = json['diseaseName']?.toString().trim() ?? 'Unknown Disease';
     debugPrint('🔄 Disease name: "$diseaseName"');

   
    final lowerDiseaseName = diseaseName.toLowerCase();
    final isHealthy = 
        lowerDiseaseName.contains('healthy') ||
        lowerDiseaseName.contains('no issue') ||
        lowerDiseaseName.contains('no disease') ||
        lowerDiseaseName.contains('normal') ||
        lowerDiseaseName.contains('no problem') ||
        diseaseName.isEmpty ||
        diseaseName == 'Unknown Disease' ||
        lowerDiseaseName == 'unknown'&&
    !lowerDiseaseName.contains('plant death') &&
    !lowerDiseaseName.contains('severe damage');


    if (isHealthy) {
      return Diagnosis(
        plantName: normalizedPlantName, 
        diseaseName: 'No Issues Detected',
    //    severityLevel: 'Healthy',
        severityLevel: json['severityLevel']?.toString().trim() == 'None' 
        ? 'Healthy'  // Map "None" to "Healthy" for UI
        : 'Healthy',
        symptoms: 'No visible symptoms of disease or pests detected. Plant appears to be in good health with normal growth patterns.',
        immediateActions: 'Continue current care routine. Maintain optimal growing conditions and monitor plant health regularly.',
        treatmentPlan: 'No treatment required. Focus on preventive care including proper watering, adequate lighting, and balanced nutrition.',
        dailyMonitoring: 'Check for changes in leaf color, texture, or growth patterns weekly. Monitor soil moisture and overall plant vigor.',
        expectedRecovery: 'Plant is healthy and does not require recovery. Maintain current care practices for continued health.',
      );
    }
    
    
    return Diagnosis(
      plantName: normalizedPlantName, 
      diseaseName: diseaseName,
      severityLevel: _validateSeverity(json['severityLevel']?.toString().trim()),
      symptoms: json['symptoms']?.toString().trim() ?? 'No specific symptoms identified. Further observation recommended.',
      immediateActions: json['immediateActions']?.toString().trim() ?? 'Isolate plant to prevent spread. Remove visibly affected areas and improve growing conditions.',
      treatmentPlan: json['treatmentPlan']?.toString().trim() ?? 'Consult with plant specialist for accurate treatment plan based on specific condition.',
      dailyMonitoring: json['dailyMonitoring']?.toString().trim() ?? 'Monitor plant response to treatment daily. Document changes in symptoms and overall health.',
      expectedRecovery: json['expectedRecovery']?.toString().trim() ?? 'Recovery timeline varies based on treatment adherence, plant health, and environmental conditions.',
    );
  }

  static String _validateSeverity(String? severity) {
    if (severity == null || severity.isEmpty) return 'Moderate';
    
    final lowerSeverity = severity.toLowerCase();
    if (lowerSeverity.contains('mild')) return 'Mild';
    if (lowerSeverity.contains('moderate')) return 'Moderate';
    if (lowerSeverity.contains('severe')) return 'Severe';
    if (lowerSeverity.contains('critical')) return 'Critical';
    
    return 'Moderate'; // Default fallback
  }

  
  static String _normalizePlantName(String rawName) {
    if (rawName.isEmpty) return 'Unknown Plant';
    

    String name = rawName.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
    
   
    name = name.replaceAll(RegExp(r'\s*(Plant|Tree|Flower|Bush|Shrub)$', caseSensitive: false), '');
    
  
    name = name.trim();
    
    
    name = name.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    // Handle common variations
    final nameVariations = {
      'Pathos': 'Pothos',
      'Caladiums': 'Caladium',
      'Roses': 'Rose',
      'Snake Plants': 'Snake Plant',
    };
    
    return nameVariations[name] ?? name;
  }

  // For demo purposes 
  factory Diagnosis.demo() {
    return Diagnosis(
      plantName: 'Swiss Cheese Plant',
      diseaseName: 'Leaf Spot Disease',
      severityLevel: 'Moderate',
      symptoms: 'Circular brown spots with yellow halos on leaves, spots may coalesce forming larger necrotic areas, possible leaf yellowing around affected regions.',
      immediateActions: '1. Remove all affected leaves using sterilized tools\n2. Isolate plant from others immediately\n3. Stop overhead watering to prevent spread\n4. Increase air circulation around plant\n5. Disinfect tools after use',
      treatmentPlan: 'Initial Treatment: Copper-based fungicide application for 2 weeks\n- Application Method: Foliar spray covering all leaf surfaces\n- Frequency: Every 7-10 days\n\nFollow-up Treatment: Neem oil solution for 3 weeks\n- Application: Thorough spray on leaves and stems\n- Frequency: Weekly application\n\nPreventive Measures: Improve growing conditions and avoid leaf wetness',
      dailyMonitoring: '1. Check for new spot development daily\n2. Monitor soil moisture - water only when top inch is dry\n3. Maintain 40-50% humidity levels\n4. Ensure proper drainage to prevent root issues\n5. Document plant response to treatment',
      expectedRecovery: 'With proper treatment and care, significant improvement should be visible within 2-3 weeks. Complete recovery may take 4-6 weeks depending on plant overall health and environmental conditions.',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantName': plantName,
      'diseaseName': diseaseName,
      'severityLevel': severityLevel,
      'symptoms': symptoms,
      'immediateActions': immediateActions,
      'treatmentPlan': treatmentPlan,
      'dailyMonitoring': dailyMonitoring,
      'expectedRecovery': expectedRecovery,
    };
  }

  // NEW HELPER METHODS FOR WIDGET REUSABILITY 


  List<Map<String, String>> getTreatmentItems() {
    final List<Map<String, String>> items = [];
    
    // Parse treatment plan to extract structured treatment information
    if (treatmentPlan.contains('Initial Treatment:')) {
      final parts = treatmentPlan.split('Initial Treatment:');
      if (parts.length > 1) {
        final treatmentText = parts[1].split('\n\n')[0].trim();
        items.add({
          'treatment': treatmentText,
          'duration': '2 weeks',
          'frequency': 'Every 7-10 days',
          'type': 'Initial',
        });
      }
    }
    
    if (treatmentPlan.contains('Follow-up Treatment:')) {
      final parts = treatmentPlan.split('Follow-up Treatment:');
      if (parts.length > 1) {
        final treatmentText = parts[1].split('\n\n')[0].trim();
        items.add({
          'treatment': treatmentText,
          'duration': '3 weeks',
          'frequency': 'Weekly application',
          'type': 'Follow-up',
        });
      }
    }
    
    // Fallback: if no structured treatments found, create one from the entire plan
    if (items.isEmpty && treatmentPlan.isNotEmpty) {
      items.add({
        'treatment': treatmentPlan,
        'duration': 'As recommended',
        'frequency': 'Follow instructions',
        'type': 'General',
      });
    }
    
    return items;
  }

  /// Extracts monitoring checklist items for display with checkmarks
  List<String> getMonitoringChecklist() {
   
    final items = dailyMonitoring.split('\n')
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim())
        .toList();
    
    // If no clear list structure found, create a simple list from the text
    if (items.isEmpty || (items.length == 1 && items.first.length > 100)) {
      // Split long text into sentences for better display
      return _splitIntoChecklistItems(dailyMonitoring);
    }
    
    return items;
  }


  List<String> getImmediateActionsList() {
    // Split by newlines and filter out empty items
    final items = immediateActions.split('\n')
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim())
        .toList();
    
    // If no clear list structure found, create a simple list from the text
    if (items.isEmpty || (items.length == 1 && items.first.length > 100)) {
      return _splitIntoChecklistItems(immediateActions);
    }
    
    return items;
  }

  /// Helper method to split long text into checklist items
  List<String> _splitIntoChecklistItems(String text) {
    // Split by common sentence endings and numbers
    final sentences = text.split(RegExp(r'[.!?]|\d+\.'));
    return sentences
        .where((sentence) => sentence.trim().isNotEmpty)
        .map((sentence) => sentence.trim())
        .take(5) // Limit to 5 items for better UI
        .toList();
  }

  /// Helper to check if plant is healthy (for conditional UI rendering)
  bool get isHealthy {
    return diseaseName.toLowerCase().contains('no issues') ||
           diseaseName.toLowerCase().contains('healthy') ||
           severityLevel.toLowerCase().contains('healthy');
  }

  /// Get color for severity level (for UI consistency)
  String getSeverityColor() {
    switch (severityLevel.toLowerCase()) {
      case 'mild': return 'orange';
      case 'moderate': return 'orangeAccent';
      case 'severe': return 'red';
      case 'critical': return 'redAccent';
      case 'healthy': return 'green';
      default: return 'orange';
    }
  }
}