class WaterCalculation {
  final String plantName;
  final String waterAmount;
  final String explanation;
  final String frequency;
  final String bestTime;
  final List<String> tips;

  WaterCalculation({
    required this.plantName,
    required this.waterAmount,
    required this.explanation,
    required this.frequency,
    required this.bestTime,
    required this.tips,
  });

  factory WaterCalculation.fromJson(Map<String, dynamic> json) {
    
  
  return WaterCalculation(
    plantName: json['plantName']?.toString().trim() ?? 'Your Plant',
    waterAmount: json['waterAmount']?.toString().trim() ?? '250-300 ML', 
    explanation: json['explanation']?.toString().trim() ?? 'Optimal watering amount calculated based on plant type and environmental conditions.',
    frequency: json['frequency']?.toString().trim() ?? 'Adjust based on soil moisture check',
    bestTime: json['bestTime']?.toString().trim() ?? 'Morning hours',
    tips: List<String>.from(json['tips']?.map((tip) => tip.toString().trim()) ?? []), // Empty list if no tips
  );
}

  Map<String, dynamic> toMap() {
    return {
      'plantName': plantName,
      'waterAmount': waterAmount,
      'explanation': explanation,
      'frequency': frequency,
      'bestTime': bestTime,
      'tips': tips,
    };
  }
}
