import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';
import 'lendings_filter_cubit/lendings_filter_cubit.dart';

class LendingsCubit extends Cubit<List<LendingWithData>?> {
  LendingsCubit(this.dao) : super(null) {
    subscription = dao.watchLendingsWithData().listen(emit);
  }

  final LendingsDao dao;
  StreamSubscription<List<LendingWithData>>? subscription;

  Future<DatabaseException?> delete(LendingWithData lendingWithData) async {
    try {
      final rowsAffected = await dao.deleteLending(lendingWithData.lending);
      return rowsAffected > 0 ? null : DatabaseException.unknown;
    } on SqliteException {
      return DatabaseException.unknown;
    }
  }

  void filter(LendingsFilterState filterState) {
    subscription?.cancel();
    subscription = dao
        .watchLendingsWithData(
          categoriesFilter: filterState.categories.map((c) => c.id),
          peopleFilter: filterState.people.map((p) => p.id),
          borrowedFilter: filterState.type == LendingsType.all
              ? null
              : filterState.type == LendingsType.borrowed,
          returnedFilter: filterState.status == LendingsStatus.all
              ? null
              : filterState.status == LendingsStatus.returned,
        )
        .listen(emit);
  }

  Future<DatabaseException?> markReturned(
      LendingWithData lendingWithData) async {
    try {
      final lendingCompanion = lendingWithData.lending.toCompanion(false);
      final updateSuccessful = await dao.updateLending(
          lendingCompanion.copyWith(returnDate: Value(DateTime.now())));
      if (!updateSuccessful) {
        return DatabaseException.unknown;
      }
    } on SqliteException {
      return DatabaseException.unknown;
    }
  }

  Future<bool> undoDelete(LendingWithData lendingWithData) async {
    try {
      await dao.createLending(lendingWithData.lending);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> undoReturn(LendingWithData lendingWithData) async {
    try {
      final lendingCompanion = lendingWithData.lending.toCompanion(false);
      return await dao.updateLending(
          lendingCompanion.copyWith(returnDate: const Value(null)));
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
