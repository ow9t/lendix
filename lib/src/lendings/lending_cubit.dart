import 'package:drift/drift.dart' hide JsonKey;
import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

class LendingCubit extends Cubit<LendingsCompanion> {
  LendingCubit(this.dao, [LendingsCompanion? companion])
      : super(companion ?? const LendingsCompanion());

  final LendingsDao dao;

  void saveBorrowed(bool isBorrowed) =>
      emit(state.copyWith(isBorrowed: Value(isBorrowed)));

  void saveDate(DateTime date) => emit(state.copyWith(date: Value(date)));

  void saveItem(int itemId) => emit(state.copyWith(itemId: Value(itemId)));

  void savePerson(int personId) =>
      emit(state.copyWith(personId: Value(personId)));

  void saveReturnDate(DateTime? returnDate) =>
      emit(state.copyWith(returnDate: Value(returnDate)));

  Future<DatabaseException?> submit() async {
    final isNew = !state.id.present;
    try {
      if (isNew) {
        await dao.createLending(state);
      } else {
        await dao.updateLending(state);
      }
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067) {
        return DatabaseException.uniqueConstraint;
      } else {
        return DatabaseException.unknown;
      }
    }
  }
}
