part of 'database.dart';

@DriftAccessor(tables: [Categories, Items, Lendings, People])
class LendingsDao extends DatabaseAccessor<MyDatabase> with _$LendingsDaoMixin {
  LendingsDao(MyDatabase attachedDatabase) : super(attachedDatabase);

  JoinedSelectStatement<HasResultSet, dynamic> _filter(
    JoinedSelectStatement<HasResultSet, dynamic> statement, {
    String itemFilter = '',
    Iterable<int> categoriesFilter = const [],
    Iterable<int> peopleFilter = const [],
    bool? borrowedFilter,
    bool? returnedFilter,
  }) {
    if (itemFilter.isNotEmpty) {
      statement.where(items.name.like('%$itemFilter%'));
    }
    if (categoriesFilter.isNotEmpty) {
      statement.where(categories.id.isIn(categoriesFilter));
    }
    if (peopleFilter.isNotEmpty) {
      statement.where(lendings.personId.isIn(peopleFilter));
    }
    if (borrowedFilter != null) {
      statement.where(lendings.isBorrowed.equals(borrowedFilter));
    }
    if (returnedFilter != null) {
      if (returnedFilter) {
        statement.where(lendings.returnDate.isNotNull());
      } else {
        statement.where(lendings.returnDate.isNull());
      }
    }
    return statement;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _join(
          SimpleSelectStatement<$LendingsTable, Lending> statement) =>
      statement.join([
        innerJoin(people, lendings.personId.equalsExp(people.id)),
        innerJoin(items, lendings.itemId.equalsExp(items.id)),
        leftOuterJoin(categories, categories.id.equalsExp(items.categoryId)),
      ]);

  Selectable<LendingWithData> _map(
          JoinedSelectStatement<HasResultSet, dynamic> statement) =>
      statement.map((row) => LendingWithData(
            lending: row.readTable(lendings),
            person: row.readTable(people),
            item: row.readTable(items),
            category: row.readTableOrNull(categories),
          ));

  Future<int> createLending(Insertable<Lending> lending) =>
      into(lendings).insert(lending);

  Future<int> createLendingWithData({
    required String itemName,
    String? categoryName,
    required String personName,
    required DateTime date,
    DateTime? returnDate,
    bool isBorrowed = false,
  }) async {
    final itemId = await db.itemsDao.createItemWithCategorySafe(
      itemName: itemName,
      categoryName: categoryName,
    );
    final personId = await db.peopleDao.createPersonByNameSafe(personName);
    return into(lendings).insert(LendingsCompanion.insert(
      itemId: itemId,
      personId: personId,
      date: date,
      returnDate: Value(returnDate),
      isBorrowed: Value(isBorrowed),
    ));
  }

  Future<Lending?> getLendingById(int id) =>
      (select(lendings)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<LendingWithData?> getLendingWithDataById(int id) async =>
      _map(_join(select(lendings)..where((l) => l.id.equals(id))))
          .getSingleOrNull();

  Future<bool> updateLending(Insertable<Lending> lending) =>
      update(lendings).replace(lending);

  Future<int> deleteLending(Insertable<Lending> lending) =>
      delete(lendings).delete(lending);

  Stream<List<LendingWithData>> watchLendingsWithData({
    String itemFilter = '',
    Iterable<int> categoriesFilter = const [],
    Iterable<int> peopleFilter = const [],
    bool? borrowedFilter,
    bool? returnedFilter,
  }) =>
      _map(
        _filter(
          _join(select(lendings)),
          itemFilter: itemFilter,
          categoriesFilter: categoriesFilter,
          peopleFilter: peopleFilter,
          borrowedFilter: borrowedFilter,
          returnedFilter: returnedFilter,
        )..orderBy([
            OrderingTerm.desc(lendings.date),
          ]),
      ).watch();
}
