import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

class CategoriesCubit extends Cubit<List<Category>?> {
  CategoriesCubit(this.dao) : super(null) {
    subscription = dao.watchCategories().listen(emit);
  }

  final CategoriesDao dao;
  StreamSubscription<List<Category>>? subscription;

  Future<DatabaseException?> delete(Category category) async {
    try {
      final rowsAffected = await dao.deleteCategory(category);
      return rowsAffected > 0 ? null : DatabaseException.unknown;
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 787) {
        return DatabaseException.foreignKeyConstraint;
      } else {
        return DatabaseException.unknown;
      }
    }
  }

  Future<bool> undo(Category category) async {
    try {
      await dao.createCategory(category);
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
