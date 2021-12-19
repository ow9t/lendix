part of 'database.dart';

class CustomDateTimeConverter extends TypeConverter<DateTime, String> {
  const CustomDateTimeConverter();

  @override
  DateTime? mapToDart(String? fromDb) {
    return fromDb == null ? null : DateTime.parse(fromDb);
  }

  @override
  String? mapToSql(DateTime? value) {
    final format = DateFormat('yyyy-MM-dd');
    return value == null ? null : format.format(value);
  }
}

class ItemWithCategory {
  final Item item;
  final Category? category;

  ItemWithCategory({required this.item, this.category});

  @override
  String toString() => 'ItemWithCategory(item: $item, category: $category)';
}

class LendingWithData {
  final Lending lending;
  final Person person;
  final Item item;
  final Category? category;

  LendingWithData({
    required this.lending,
    required this.person,
    required this.item,
    this.category,
  });

  @override
  String toString() =>
      'LendingWithData(lending: $lending, person: $person, item: $item, category: $category)';
}
