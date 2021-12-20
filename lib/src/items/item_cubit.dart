import 'package:drift/drift.dart' hide JsonKey;
import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

class ItemCubit extends Cubit<ItemsCompanion> {
  ItemCubit(this.dao, [ItemsCompanion? companion])
      : super(companion ?? ItemsCompanion.insert(name: ''));

  final ItemsDao dao;

  void saveCategory(int? categoryId) =>
      emit(state.copyWith(categoryId: Value(categoryId)));

  void saveName(String name) => emit(state.copyWith(name: Value(name)));

  Future<DatabaseException?> submit() async {
    final isNew = !state.id.present;
    try {
      late final int id;
      if (isNew) {
        id = await dao.createItem(state);
      } else {
        id = state.id.value;
        await dao.updateItem(state);
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
