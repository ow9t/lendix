part of 'database.dart';

const categoryNameMaxLength = 40;
const itemNameMaxLength = 80;
const personNameMaxLength = 80;

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  // code generator does not generate constraints when we use max length constants
  TextColumn get name =>
      text().withLength(min: 1, max: 40).customConstraint('NOT NULL UNIQUE')();
}

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  // code generator does not generate constraints when we use max length constants
  TextColumn get name => text().withLength(min: 1, max: 80)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
}

@DataClassName('Person')
class People extends Table {
  IntColumn get id => integer().autoIncrement()();
  // code generator does not generate constraints when we use max length constants
  TextColumn get name =>
      text().withLength(min: 1, max: 80).customConstraint('NOT NULL UNIQUE')();
}

class Lendings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer()();
  IntColumn get personId => integer()();
  TextColumn get date => text().map(const CustomDateTimeConverter())();
  TextColumn get returnDate =>
      text().map(const CustomDateTimeConverter()).nullable()();
  BoolColumn get isBorrowed => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY(item_id) REFERENCES items(id)',
        'FOREIGN KEY(person_id) REFERENCES people(id)',
        'UNIQUE(item_id, person_id, date)',
      ];
}
