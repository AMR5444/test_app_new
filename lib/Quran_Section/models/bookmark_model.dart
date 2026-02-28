class BookmarkModel {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'ayahText': ayahText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) => BookmarkModel(
    id: json['id'],
    surahNumber: json['surahNumber'],
    ayahNumber: json['ayahNumber'],
    ayahText: json['ayahText'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
