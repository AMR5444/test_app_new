class SurahModel {
  final int number;
  final String name;
  final String englishName;
  final String? englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory SurahModel.fromjson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      revelationType: json['revelationType'],
      numberOfAyahs: json['numberOfAyahs'],
    );
  }
}
