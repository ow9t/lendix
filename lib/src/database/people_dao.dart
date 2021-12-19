part of 'database.dart';

@DriftAccessor(tables: [People])
class PeopleDao extends DatabaseAccessor<MyDatabase> with _$PeopleDaoMixin {
  PeopleDao(MyDatabase attachedDatabase) : super(attachedDatabase);

  SimpleSelectStatement<$PeopleTable, Person> _filter(
    SimpleSelectStatement<$PeopleTable, Person> statement, {
    String nameFilter = '',
  }) {
    if (nameFilter.isNotEmpty) {
      statement.where((p) => p.name.like('%$nameFilter%'));
    }
    return statement;
  }

  Future<int> createPerson(Insertable<Person> person) =>
      into(people).insert(person);

  Future<int> createPersonByName(String name) =>
      into(people).insert(PeopleCompanion.insert(name: name));

  Future<int> createPersonByNameSafe(String name) async {
    final maybePerson = await getPersonByName(name);
    return maybePerson?.id ?? await createPersonByName(name);
  }

  Future<Person?> getPersonById(int id) =>
      (select(people)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<Person?> getPersonByName(String name) =>
      (select(people)..where((p) => p.name.equals(name))).getSingleOrNull();

  Future<bool> updatePerson(Insertable<Person> person) =>
      update(people).replace(person);

  Future<int> deletePerson(Insertable<Person> person) =>
      delete(people).delete(person);

  Stream<List<Person>> watchPeople({String nameFilter = ''}) => _filter(
        select(people)..orderBy([(p) => OrderingTerm.asc(p.name)]),
        nameFilter: nameFilter,
      ).watch();
}
