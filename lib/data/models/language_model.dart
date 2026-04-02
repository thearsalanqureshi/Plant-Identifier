class LanguageModel {
  final String code;
  final String name;
  // final String nativeName;

  const LanguageModel({
    required this.code,
    required this.name,
   // required this.nativeName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}