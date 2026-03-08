import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Plant {
  @HiveField(0)
  final String plantName;
  
  @HiveField(1)
  final String scientificName;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String temperature;
  
  @HiveField(4)
  final String light;
  
  @HiveField(5)
  final String soil;
  
  @HiveField(6)
  final String humidity;
  
  @HiveField(7)
  final String watering;
  
  @HiveField(8)
  final String fertilizing;
  
  @HiveField(9)
  final String toxicity;

  Plant({
    required this.plantName,
    required this.scientificName,
    required this.description,
    required this.temperature,
    required this.light,
    required this.soil,
    required this.humidity,
    required this.watering,
    required this.fertilizing,
    required this.toxicity,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    final plantName = json['plantName']?.toString().trim() ?? 'Unknown Plant';
    final scientificName = json['scientificName']?.toString().trim() ?? 'Unknown Species';
    
    // Enhanced validation for identification accuracy
    final isUnidentified = 
        plantName.toLowerCase().contains('unknown') ||
        scientificName.toLowerCase().contains('unknown') ||
        plantName.isEmpty;

    if (isUnidentified) {
      return Plant(
        plantName: 'Unidentified Plant',
        scientificName: 'Species Not Recognized',
        description: 'Unable to accurately identify this plant. Please ensure the image is clear and shows distinct plant features. Try taking photos of leaves, stems, and flowers if available.',
        temperature: 'Consult plant specialist for requirements',
        light: 'Moderate indirect light recommended until identified',
        soil: 'Well-draining potting mix generally suitable',
        humidity: 'Average room humidity (40-50%)',
        watering: 'Water when top soil is dry - amount varies by size',
        fertilizing: 'General purpose fertilizer at half strength',
        toxicity: 'Assume potentially toxic until identified - keep away from children and pets',
      );
    }
    
    return Plant(
      plantName: plantName,
      scientificName: scientificName,
      description: json['description']?.toString().trim() ?? 'No detailed description available. General care instructions provided based on plant type.',
      temperature: json['temperature']?.toString().trim() ?? '18-25°C (typical indoor range)',
      light: json['light']?.toString().trim() ?? 'Bright indirect light',
      soil: json['soil']?.toString().trim() ?? 'Well-draining potting mix',
      humidity: json['humidity']?.toString().trim() ?? '40-60%',
      watering: json['watering']?.toString().trim() ?? 'Water when top inch of soil is dry',
      fertilizing: json['fertilizing']?.toString().trim() ?? 'Balanced fertilizer during growing season',
      toxicity: json['toxicity']?.toString().trim() ?? 'Safety information not available - exercise caution',
    );
  }

  // Enhanced demo data
  factory Plant.demo() {
    return Plant(
      plantName: 'Monstera Deliciosa',
      scientificName: 'Monstera deliciosa',
      description: 'Native to tropical rainforests of Central America. A popular evergreen tropical vine known for its large, glossy, heart-shaped leaves that develop characteristic splits and holes (fenestrations) as they mature. Can grow up to 3 meters indoors with proper support.',
      temperature: '18-29°C (65-85°F). Avoid temperatures below 15°C (59°F)',
      light: 'Bright, indirect light. Can tolerate medium light but growth slows. Avoid direct sun which can scorch leaves.',
      soil: 'Well-draining, peat-based potting mix with perlite or orchid bark for aeration. pH 5.5-7.0',
      humidity: '60-80% ideal. Can tolerate 40% but may develop brown leaf edges in dry conditions.',
      watering: '200-300ml per session when top 2-3cm of soil is dry. Reduce to 150-200ml in winter months.',
      fertilizing: 'Balanced liquid fertilizer (20-20-20) diluted to half strength every 2-4 weeks during spring and summer. No fertilizer in winter.',
      toxicity: 'Toxic to cats and dogs if ingested due to calcium oxalate crystals. May cause oral irritation and digestive upset.',
    );
  }

  // Convert to map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'plantName': plantName,
      'scientificName': scientificName,
      'description': description,
      'temperature': temperature,
      'light': light,
      'soil': soil,
      'humidity': humidity,
      'watering': watering,
      'fertilizing': fertilizing,
      'toxicity': toxicity,
    };
  }

  
}