import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

part 'categories_dao.dart';
part 'helper_classes.dart';
part 'items_dao.dart';
part 'lendings_dao.dart';
part 'people_dao.dart';
part 'tables.dart';

// SqliteException(787): FOREIGN KEY constraint failed
// SqliteException(2067): UNIQUE constraint failed
enum DatabaseException { unknown, foreignKeyConstraint, uniqueConstraint }

LazyDatabase openLazy(String filename) {
  return LazyDatabase(() async {
    final dbDirectory = await getApplicationDocumentsDirectory();
    final dbFile = File(join(dbDirectory.path, filename));
    return NativeDatabase(dbFile);
  });
}

@DriftDatabase(
  tables: [Categories, Items, Lendings, People],
  daos: [CategoriesDao, ItemsDao, LendingsDao, PeopleDao],
)
class MyDatabase extends _$MyDatabase {
  MyDatabase(QueryExecutor executor) : super(executor);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (migrator) async {
          await migrator.createAll();
          await customStatement(
              'CREATE UNIQUE INDEX tx ON items(name, ifnull(category_id, 0))');
        },
      );

  @override
  int get schemaVersion => 1;
}
