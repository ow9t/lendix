part of 'database.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<MyDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(MyDatabase attachedDatabase) : super(attachedDatabase);

  SimpleSelectStatement<$CategoriesTable, Category> _filter(
    SimpleSelectStatement<$CategoriesTable, Category> statement, {
    String nameFilter = '',
  }) {
    if (nameFilter.isNotEmpty) {
      statement.where((c) => c.name.like('%$nameFilter%'));
    }
    return statement;
  }

  Future<int> createCategory(Insertable<Category> category) =>
      into(categories).insert(category);

  Future<int> createCategoryByName(String name) =>
      into(categories).insert(CategoriesCompanion.insert(name: name));

  Future<int> createCategoryByNameSafe(String name) async {
    final maybeCategory = await getCategoryByName(name);
    return maybeCategory?.id ?? await createCategoryByName(name);
  }

  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<Category?> getCategoryByName(String name) =>
      (select(categories)..where((c) => c.name.equals(name))).getSingleOrNull();

  Future<bool> updateCategory(Insertable<Category> category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(Insertable<Category> category) =>
      delete(categories).delete(category);

  Stream<List<Category>> watchCategories({String nameFilter = ''}) => _filter(
        select(categories)..orderBy([(c) => OrderingTerm.asc(c.name)]),
        nameFilter: nameFilter,
      ).watch();
}
