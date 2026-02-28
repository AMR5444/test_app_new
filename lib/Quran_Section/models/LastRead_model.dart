class LastRead {
  final int surahNumber;
  final int pageIndex;

  LastRead({required this.surahNumber, required this.pageIndex});

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'pageIndex': pageIndex,
  };

  factory LastRead.fromJson(Map<String, dynamic> json) =>
      LastRead(surahNumber: json['surahNumber'], pageIndex: json['pageIndex']);
}
