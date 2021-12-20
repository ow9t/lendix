import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

class ItemsCubit extends Cubit<List<ItemWithCategory>?> {
  ItemsCubit(this.dao) : super(null) {
    subscription = dao.watchItemsWithCategory().listen(emit);
  }

  final ItemsDao dao;
  StreamSubscription<List<ItemWithCategory>>? subscription;

  Future<DatabaseException?> delete(ItemWithCategory itemWithCategory) async {
    try {
      final rowsAffected = await dao.deleteItem(itemWithCategory.item);
      return rowsAffected > 0 ? null : DatabaseException.unknown;
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 787) {
        return DatabaseException.foreignKeyConstraint;
      } else {
        return DatabaseException.unknown;
      }
    }
  }

  void filter(Iterable<Category> categories) {
    subscription?.cancel();
    subscription = dao
        .watchItemsWithCategory(categoriesFilter: categories.map((c) => c.id))
        .listen(emit);
  }

  Future<bool> undo(ItemWithCategory itemWithCategory) async {
    try {
      await dao.createItem(itemWithCategory.item);
      return true;
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
