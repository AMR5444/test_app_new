import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/tasbeeh_section/data/tasbeeh_storage.dart';
import 'package:test_app_new/tasbeeh_section/logic/tasbeeh_state.dart';
import 'package:test_app_new/tasbeeh_section/models/tasbeeh_model.dart';

export 'tasbeeh_state.dart';

class TasbeehCubit extends Cubit<TasbeehState> {
  TasbeehCubit({TasbeehStorage? storage, List<TasbeehModel>? azkarList})
    : _storage = storage ?? TasbeehStorage(),
      super(TasbeehState(azkarList: azkarList ?? TasbeehModel.defaults)) {
    _restoreState();
  }

  final TasbeehStorage _storage;

  Future<void> _restoreState() async {
    final saved = await _storage.load();
    if (isClosed) return;

    if (state.azkarList.isEmpty) {
      emit(state.copyWith(isReady: true));
      return;
    }

    var selectedIndex = 0;
    if (saved.selectedZekr != null) {
      final foundIndex = state.azkarList.indexWhere(
        (zekr) => zekr.zekr == saved.selectedZekr,
      );
      if (foundIndex != -1) selectedIndex = foundIndex;
    }

    final defaultTarget = state.azkarList[selectedIndex].target;
    final restoredTarget = saved.target ?? defaultTarget;
    final restoredCount = saved.count ?? 0;

    emit(
      state.copyWith(
        selectedIndex: selectedIndex,
        count: restoredCount,
        target: restoredTarget,
        isReady: true,
      ),
    );
  }

  void increment() {
    if (!state.isReady) return;

    final newCount = state.count + 1;
    emit(state.copyWith(count: newCount));
    unawaited(_storage.saveCount(newCount));
  }

  /// Resets the counter back to zero and persists it.
  void reset() {
    if (!state.isReady || state.count == 0) return;

    emit(state.copyWith(count: 0));
    unawaited(_storage.saveCount(0));
  }

  void changeZekr(int index) {
    if (!state.isReady) return;
    if (index < 0 || index >= state.azkarList.length) return;
    if (index == state.selectedIndex) return;

    final zekr = state.azkarList[index];
    emit(state.copyWith(selectedIndex: index, count: 0, target: zekr.target));
    unawaited(_storage.saveSelectedZekr(zekr.zekr));
    unawaited(_storage.saveCount(0));
    unawaited(_storage.saveTarget(zekr.target));
  }

  void changeTarget(int target) {
    if (!state.isReady) return;
    if (target <= 0) return;

    emit(state.copyWith(target: target));
    unawaited(_storage.saveTarget(target));
  }
}
