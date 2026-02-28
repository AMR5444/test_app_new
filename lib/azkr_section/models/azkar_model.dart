class ZekrItem {
  final String text;
  final String content;
  final int count;
  int currentCount;
  final String description;

  ZekrItem({
    required this.text,
    required this.content,
    required this.count,
    required this.description,
  }) : currentCount = count;

  factory ZekrItem.fromJson(Map<String, dynamic> json) {
    return ZekrItem(
      content: json['content'] ?? '',
      count: int.tryParse(json['count'].toString()) ?? 1,
      description: json['description'] ?? '',
      text: '',
    );
  }
}
