const String kBasmalaText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

class MushafWordModel {
  final String text;
  final int ayahNumberInSurah;

  MushafWordModel({required this.text, required this.ayahNumberInSurah});

  factory MushafWordModel.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] as String).split(':');

    return MushafWordModel(
      text: json['word'] as String,
      ayahNumberInSurah: int.parse(location[1]),
    );
  }

  Map<String, dynamic> toJson() => {
    'word': text,
    'location': '0:$ayahNumberInSurah:0',
  };
}

class MushafLineModel {
  final int line;
  final String type;
  final String? surahHeaderText;
  final List<MushafWordModel> words;

  MushafLineModel({
    required this.line,
    required this.type,
    this.surahHeaderText,
    this.words = const [],
  });

  factory MushafLineModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final wordsJson = json['words'] as List?;

    return MushafLineModel(
      line: json['line'] as int,
      type: type,
      surahHeaderText: type == 'surah-header' ? json['text'] as String? : null,
      words:
          wordsJson
              ?.map(
                (w) => MushafWordModel.fromJson(
                  Map<String, dynamic>.from(w as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'line': line,
    'type': type,
    'text': surahHeaderText,
    'words': words.map((w) => w.toJson()).toList(),
  };
}

class MushafPageLayoutModel {
  final int page;
  final List<MushafLineModel> lines;

  MushafPageLayoutModel({required this.page, required this.lines});

  factory MushafPageLayoutModel.fromJson(Map<String, dynamic> json) {
    final linesJson = json['lines'] as List;

    return MushafPageLayoutModel(
      page: json['page'] as int,
      lines: linesJson
          .map(
            (e) =>
                MushafLineModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'lines': lines.map((l) => l.toJson()).toList(),
  };
}
