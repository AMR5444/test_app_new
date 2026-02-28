class NoteModel {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final String noteText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NoteModel({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.noteText,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'ayahText': ayahText,
    'noteText': noteText,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json['id'],
    surahNumber: json['surahNumber'],
    ayahNumber: json['ayahNumber'],
    ayahText: json['ayahText'],
    noteText: json['noteText'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );
}
