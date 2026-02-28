import 'package:hive_flutter/adapters.dart';
part 'ayah_model.g.dart';

@HiveType(typeId: 1)
class AyahModel extends HiveObject {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final int numberInSurah;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final int page;

  AyahModel({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.page,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      number: json['number'],
      numberInSurah: json['numberInSurah'],
      text: json['text'],
      page: json['page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'numberInSurah': numberInSurah,
      'text': text,
      'page': page,
    };
  }
}
