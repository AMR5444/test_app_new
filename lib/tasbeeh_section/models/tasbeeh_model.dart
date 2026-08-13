class TasbeehModel {
  final String zekr;
  final String description;
  final int count;
  final int target;

  const TasbeehModel({
    required this.zekr,
    required this.description,
    required this.count,
    required this.target,
  });

  TasbeehModel copyWith({
    String? zekr,
    String? description,
    int? count,
    int? target,
  }) => TasbeehModel(
    zekr: zekr ?? this.zekr,
    description: description ?? this.description,
    count: count ?? this.count,
    target: target ?? this.target,
  );

  static const List<TasbeehModel> defaults = [
    TasbeehModel(
      zekr: 'سبحان الله',
      description: 'تنزيه الله سبحانه وتعالى عن كل نقص',
      count: 0,
      target: 33,
    ),
    TasbeehModel(
      zekr: 'الحمد لله',
      description: 'حمد الله والثناء عليه على نعمه',
      count: 0,
      target: 33,
    ),
    TasbeehModel(
      zekr: 'الله أكبر',
      description: 'تكبير الله وتعظيمه',
      count: 0,
      target: 34,
    ),
    TasbeehModel(
      zekr: 'لا إله إلا الله',
      description: 'كلمة التوحيد والإخلاص لله وحده',
      count: 0,
      target: 100,
    ),
    TasbeehModel(
      zekr: 'أستغفر الله',
      description: 'طلب المغفرة والتوبة إلى الله',
      count: 0,
      target: 100,
    ),
  ];
}
