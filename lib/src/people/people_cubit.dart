import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

class PeopleCubit extends Cubit<List<Person>?> {
  PeopleCubit(this.dao) : super(null) {
    subscription = dao.watchPeople().listen(emit);
  }

  final PeopleDao dao;
  StreamSubscription<List<Person>>? subscription;

  Future<DatabaseException?> delete(Person person) async {
    try {
      final rowsAffected = await dao.deletePerson(person);
      return rowsAffected > 0 ? null : DatabaseException.unknown;
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 787) {
        return DatabaseException.foreignKeyConstraint;
      } else {
        return DatabaseException.unknown;
      }
    }
  }

  Future<bool> undo(Person person) async {
    try {
      await dao.createPerson(person);
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
