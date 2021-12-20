import 'package:drift/drift.dart' hide JsonKey;
import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

class PersonCubit extends Cubit<PeopleCompanion> {
  PersonCubit(this.dao, [PeopleCompanion? companion])
      : super(companion ?? PeopleCompanion.insert(name: ''));

  final PeopleDao dao;

  void save(String name) => emit(state.copyWith(name: Value(name)));

  Future<DatabaseException?> submit() async {
    final isNew = !state.id.present;
    try {
      late final int id;
      if (isNew) {
        id = await dao.createPerson(state);
      } else {
        id = state.id.value;
        await dao.updatePerson(state);
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
