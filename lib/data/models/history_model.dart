import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ScanHistory {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String type; // 'identify', 'diagnose', 'water', 'light'
  
  @HiveField(2)
  final String plantName;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final String? imagePath;
  
  @HiveField(5)
  bool isSaved;
  
  @HiveField(6)
  final bool hasAbnormality;
  
  @HiveField(7)
  final Map<String, dynamic>? resultData;

  ScanHistory({
    required this.id,
    required this.type,
    required this.plantName,
    required this.timestamp,
    this.imagePath,
    this.isSaved = false,
    this.hasAbnormality = false,
    this.resultData,
  });


ScanHistory copyWith({
    bool? isSaved,
  }) {
    return ScanHistory(
      id: id,
      type: type,
      plantName: plantName,
      timestamp: timestamp,
      imagePath: imagePath,
      isSaved: isSaved ?? this.isSaved,
      hasAbnormality: hasAbnormality,
      resultData: resultData,
    );
  }
Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'plantName': plantName,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'isSaved': isSaved,
      'hasAbnormality': hasAbnormality,
      'resultData': resultData,
    };
  }
factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'] as String,
      type: json['type'] as String,
      plantName: json['plantName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['imagePath'] as String?,
      isSaved: json['isSaved'] as bool? ?? false,
      hasAbnormality: json['hasAbnormality'] as bool? ?? false,
      resultData: json['resultData'] as Map<String, dynamic>?,
    );
  }
}