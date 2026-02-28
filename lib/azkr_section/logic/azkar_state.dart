import 'package:test_app_new/azkr_section/models/azkar_model.dart';

abstract class AzkarState {}

class AzkarInitial extends AzkarState {}

class AzkarLoading extends AzkarState {}

class AzkarLoaded extends AzkarState {
  final List<ZekrItem> azkarList;
  final String category;
  AzkarLoaded(this.azkarList, this.category);
}

class AzkarError extends AzkarState {
  final String message;
  AzkarError(this.message);
}
