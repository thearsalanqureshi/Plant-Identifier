// history_model_adapter.dart - REPLACE ENTIRE FILE:

import 'package:hive/hive.dart';
import 'history_model.dart';

class ScanHistoryAdapter extends TypeAdapter<ScanHistory> {
  @override
  final int typeId = 0;

  @override
  ScanHistory read(BinaryReader reader) {
    // READ IN EXACT SAME ORDER AS WRITE
    final id = reader.readString();
    final type = reader.readString();
    final plantName = reader.readString();
    final timestamp = DateTime.parse(reader.readString());
    final imagePath = reader.readString();
    final isSaved = reader.readBool();
    final hasAbnormality = reader.readBool();
    
    // Handle resultData properly
    final dynamicResultData = reader.read();
    Map<String, dynamic>? resultData;
    
    if (dynamicResultData is Map) {
      resultData = dynamicResultData.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    } else if (dynamicResultData != null) {
      // Fallback for corrupted data
      resultData = {'error': 'data_corrupted'};
    }

    return ScanHistory(
      id: id,
      type: type,
      plantName: plantName,
      timestamp: timestamp,
      imagePath: imagePath.isEmpty ? null : imagePath,
      isSaved: isSaved,
      hasAbnormality: hasAbnormality,
      resultData: resultData,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistory obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.type);
    writer.writeString(obj.plantName);
    writer.writeString(obj.timestamp.toIso8601String());
    writer.writeString(obj.imagePath ?? '');
    writer.writeBool(obj.isSaved);
    writer.writeBool(obj.hasAbnormality);
    
    // Write resultData or empty map
    writer.write(obj.resultData ?? {});
  }
}