import 'package:test_app_new/tasbeeh_section/models/tasbeeh_model.dart';

class TasbeehState {
  final List<TasbeehModel> azkarList;
  final int selectedIndex;
  final int count;
  final int target;
  final bool isReady;

  const TasbeehState({
    this.azkarList = const [],
    this.selectedIndex = 0,
    this.count = 0,
    this.target = 33,
    this.isReady = false,
  });

  TasbeehModel get selectedZekr {
    if (azkarList.isEmpty) {
      return const TasbeehModel(
        zekr: '',
        description: '',
        count: 0,
        target: 33,
      );
    }
    final safeIndex = selectedIndex < 0 || selectedIndex >= azkarList.length
        ? 0
        : selectedIndex;
    return azkarList[safeIndex];
  }

  double get progress {
    if (target <= 0) return 0;
    final ratio = count / target;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  bool get isTargetReached => count >= target;

  TasbeehState copyWith({
    List<TasbeehModel>? azkarList,
    int? selectedIndex,
    int? count,
    int? target,
    bool? isReady,
  }) => TasbeehState(
    azkarList: azkarList ?? this.azkarList,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    count: count ?? this.count,
    target: target ?? this.target,
    isReady: isReady ?? this.isReady,
  );
}
