import 'package:drift/drift.dart' hide JsonKey;
import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

class CategoryCubit extends Cubit<CategoriesCompanion> {
  CategoryCubit(this.dao, [CategoriesCompanion? companion])
      : super(companion ?? CategoriesCompanion.insert(name: ''));

  final CategoriesDao dao;

  void save(String name) => emit(state.copyWith(name: Value(name)));

  Future<DatabaseException?> submit() async {
    final isNew = !state.id.present;
    try {
      late final int id;
      if (isNew) {
        id = await dao.createCategory(state);
      } else {
        id = state.id.value;
        await dao.updateCategory(state);
      }
      emit(state.copyWith(id: Value(id)));
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067) {
        return DatabaseException.uniqueConstraint;
      } else {
        return DatabaseException.unknown;
      }
    }
  }
}
