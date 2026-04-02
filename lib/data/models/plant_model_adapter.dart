import 'package:hive/hive.dart';
import 'plant_model.dart';

class PlantAdapter extends TypeAdapter<Plant> {
  @override
  final int typeId = 1;

  @override
  Plant read(BinaryReader reader) {
    return Plant(
      plantName: reader.readString(),
      scientificName: reader.readString(),
      description: reader.readString(),
      temperature: reader.readString(),
      light: reader.readString(),
      soil: reader.readString(),
      humidity: reader.readString(),
      watering: reader.readString(),
      fertilizing: reader.readString(),
      toxicity: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Plant obj) {
    writer.writeString(obj.plantName);
    writer.writeString(obj.scientificName);
    writer.writeString(obj.description);
    writer.writeString(obj.temperature);
    writer.writeString(obj.light);
    writer.writeString(obj.soil);
    writer.writeString(obj.humidity);
    writer.writeString(obj.watering);
    writer.writeString(obj.fertilizing);
    writer.writeString(obj.toxicity);
  }
}