part of 'database.dart';

@DriftAccessor(tables: [Categories, Items])
class ItemsDao extends DatabaseAccessor<MyDatabase> with _$ItemsDaoMixin {
  ItemsDao(MyDatabase attachedDatabase) : super(attachedDatabase);

  SimpleSelectStatement<$ItemsTable, Item> _filter(
    SimpleSelectStatement<$ItemsTable, Item> statement, {
    String nameFilter = '',
    Iterable<int> categoriesFilter = const [],
  }) {
    if (nameFilter.isNotEmpty) {
      statement.where((i) => i.name.like('%$nameFilter%'));
    }
    if (categoriesFilter.isNotEmpty) {
      statement.where((i) => i.categoryId.isIn(categoriesFilter));
    }
    return statement;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _join(
    SimpleSelectStatement<$ItemsTable, Item> statement,
  ) =>
      statement.join([
        leftOuterJoin(categories, items.categoryId.equalsExp(categories.id)),
      ]);

  Selectable<ItemWithCategory> _map(
    JoinedSelectStatement<HasResultSet, dynamic> statement,
  ) =>
      statement.map((row) => ItemWithCategory(
            item: row.readTable(items),
            category: row.readTableOrNull(categories),
          ));

  Future<int> createItem(Insertable<Item> item) => into(items).insert(item);

  Future<int> createItemWithCategory({
    required String itemName,
    String? categoryName,
  }) async {
    late final int? categoryId;
    if (categoryName != null) {
      categoryId =
          await db.categoriesDao.createCategoryByNameSafe(categoryName);
    } else {
      categoryId = null;
    }
    return createItem(ItemsCompanion.insert(
      name: itemName,
      categoryId: Value(categoryId),
    ));
  }

  Future<int> createItemWithCategorySafe({
    required String itemName,
    String? categoryName,
  }) async {
    final maybeItemWithCategory =
        await getItemWithCategoryByNames(itemName, categoryName);
    if (maybeItemWithCategory != null) {
      return maybeItemWithCategory.item.id;
    }
    late final int? categoryId;
    if (categoryName != null) {
      categoryId =
          await db.categoriesDao.createCategoryByNameSafe(categoryName);
    } else {
      categoryId = null;
    }
    return createItem(ItemsCompanion.insert(
      name: itemName,
      categoryId: Value(categoryId),
    ));
  }

  Future<Item?> getItemById(int id) =>
      (select(items)..where((i) => i.id.equals(id))).getSingleOrNull();

  Future<ItemWithCategory?> getItemWithCategoryById(int id) =>
      _map(_join(select(items)..where((i) => i.id.equals(id))))
          .getSingleOrNull();

  Future<ItemWithCategory?> getItemWithCategoryByNames(
    String itemName, [
    String? categoryName,
  ]) {
    final statement = select(items)..where((i) => i.name.equals(itemName));
    if (categoryName == null) {
      statement.where((i) => i.categoryId.isNull());
      return _map(_join(statement)).getSingleOrNull();
    }
    return _map(_join(statement)..where(categories.name.equals(categoryName)))
        .getSingleOrNull();
  }

  Future<bool> updateItem(Insertable<Item> item) => update(items).replace(item);

  Future<int> deleteItem(Insertable<Item> item) => delete(items).delete(item);

  Stream<List<ItemWithCategory>> watchItemsWithCategory({
    String nameFilter = '',
    Iterable<int> categoriesFilter = const [],
  }) =>
      _map(
        _join(_filter(
          select(items),
          nameFilter: nameFilter,
          categoriesFilter: categoriesFilter,
        ))
          ..orderBy([
            OrderingTerm.asc(items.name),
            OrderingTerm.asc(categories.name),
          ]),
      ).watch();
}
