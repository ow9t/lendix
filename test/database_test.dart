import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lendix/src/database/database.dart';

void main() {
  late MyDatabase database;

  setUp(() {
    database = MyDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Categories', () {
    test('category can be created and retrieved by id and name', () async {
      const categoryName = 'Book';
      final id = await database.categoriesDao.createCategory(
        CategoriesCompanion.insert(name: categoryName),
      );
      expect(id, isNonNegative);
      final category = await database.categoriesDao.getCategoryById(id);
      expect(category?.name, categoryName);

      const anotherCategoryName = 'Board game';
      final anotherId = await database.categoriesDao.createCategoryByName(
        anotherCategoryName,
      );
      expect(anotherId, isNonNegative);
      final anotherCategory = await database.categoriesDao.getCategoryByName(
        anotherCategoryName,
      );
      expect(anotherCategory?.name, anotherCategoryName);
    });

    test('category name must be unique', () async {
      const categoryName = 'Book';

      final id =
          await database.categoriesDao.createCategoryByName(categoryName);
      expect(id, isNonNegative);
      final category = await database.categoriesDao.getCategoryById(id);
      expect(category?.name, categoryName);

      // SqliteException(2067): UNIQUE constraint failed
      expect(
        () => database.categoriesDao.createCategoryByName(categoryName),
        throwsA(isA<SqliteException>()),
      );
    });

    test('category name must be between 1 and 40 characters long', () async {
      const tooShort = '';
      expect(
        () => database.categoriesDao.createCategoryByName(tooShort),
        throwsA(isA<InvalidDataException>()),
      );

      const justLongEnough = '0';
      final justLongEnoughId =
          await database.categoriesDao.createCategoryByName(justLongEnough);
      expect(justLongEnoughId, isNonNegative);

      const justShortEnough = '0123456789012345678901234567890123456789';
      final justShortEnoughId =
          await database.categoriesDao.createCategoryByName(justShortEnough);
      expect(justShortEnoughId, isNonNegative);

      const tooLong = '01234567890123456789012345678901234567890';
      expect(
        () => database.categoriesDao.createCategoryByName(tooLong),
        throwsA(isA<InvalidDataException>()),
      );
    });

    test('category can be safely created by name', () async {
      const categoryName = 'Book';
      final id =
          await database.categoriesDao.createCategoryByNameSafe(categoryName);
      expect(id, isNonNegative);
      final category = await database.categoriesDao.getCategoryById(id);
      expect(category?.name, categoryName);

      final anotherId =
          await database.categoriesDao.createCategoryByNameSafe(categoryName);
      expect(anotherId, id);
    });

    test('category can be updated', () async {
      const categoryName = 'Book';
      final id =
          await database.categoriesDao.createCategoryByName(categoryName);
      expect(id, isNonNegative);
      final category = await database.categoriesDao.getCategoryById(id);
      expect(category?.name, categoryName);

      const newCategoryName = 'Board game';
      final updateSuccessful = await database.categoriesDao.updateCategory(
        category!
            .toCompanion(false)
            .copyWith(name: const Value(newCategoryName)),
      );
      expect(updateSuccessful, true);
      final updatedCategoryById =
          await database.categoriesDao.getCategoryById(id);
      expect(updatedCategoryById?.name, newCategoryName);
      final updatedCategoryByName =
          await database.categoriesDao.getCategoryByName(newCategoryName);
      expect(updatedCategoryByName?.id, id);
    });

    test('category can be deleted', () async {
      const categoryName = 'Book';
      final id =
          await database.categoriesDao.createCategoryByName(categoryName);
      expect(id, isNonNegative);
      final category = await database.categoriesDao.getCategoryById(id);
      expect(category?.name, categoryName);

      await database.categoriesDao.deleteCategory(category!);
      final deletedCategoryById =
          await database.categoriesDao.getCategoryById(id);
      expect(deletedCategoryById, isNull);
      final deletedCategoryByName =
          await database.categoriesDao.getCategoryByName(categoryName);
      expect(deletedCategoryByName, isNull);
    });

    test('categories stream emits alphabetically ordered categories', () async {
      const categoryName = 'Book';
      const anotherCategoryName = 'Board game';
      await database.categoriesDao.createCategoryByName(categoryName);
      final expectation = expectLater(
          database.categoriesDao
              .watchCategories()
              .map((categories) => categories.map((category) => category.name)),
          emitsInOrder([
            [categoryName],
            [anotherCategoryName, categoryName],
          ]));
      await database.categoriesDao.createCategoryByName(anotherCategoryName);
      await expectation;
    });

    test('categories stream can be filtered by name', () async {
      const categoryName1 = 'Book';
      const categoryName2 = 'Board game';
      const categoryName3 = 'DVD';
      await database.categoriesDao.createCategoryByName(categoryName1);
      final expectation = expectLater(
        database.categoriesDao
            .watchCategories(nameFilter: 'Bo')
            .map((categories) => categories.map((category) => category.name)),
        emitsInOrder([
          [categoryName1],
          [categoryName2, categoryName1],
          [categoryName2, categoryName1],
        ]),
      );
      await database.categoriesDao.createCategoryByName(categoryName2);
      await database.categoriesDao.createCategoryByName(categoryName3);
      await expectation;
    });
  });

  group('People', () {
    test('person can be created and retrieved by id and name', () async {
      const personName = 'Alice';
      final id = await database.peopleDao.createPerson(
        PeopleCompanion.insert(name: personName),
      );
      expect(id, isNonNegative);
      final person = await database.peopleDao.getPersonById(id);
      expect(person?.name, personName);

      const anotherPersonName = 'Bob';
      final anotherId = await database.peopleDao.createPersonByName(
        anotherPersonName,
      );
      expect(anotherId, isNonNegative);
      final anotherPerson = await database.peopleDao.getPersonByName(
        anotherPersonName,
      );
      expect(anotherPerson?.name, anotherPersonName);
    });

    test('person name must be unique', () async {
      const personName = 'Alice';

      final id = await database.peopleDao.createPersonByName(personName);
      expect(id, isNonNegative);
      final person = await database.peopleDao.getPersonById(id);
      expect(person?.name, personName);

      // SqliteException(2067): UNIQUE constraint failed
      expect(
        () => database.peopleDao.createPersonByName(personName),
        throwsA(isA<SqliteException>()),
      );
    });

    test('person name must be between 1 and 80 characters long', () async {
      const tooShort = '';
      expect(
        () => database.peopleDao.createPersonByName(tooShort),
        throwsA(isA<InvalidDataException>()),
      );

      const justLongEnough = '0';
      final justLongEnoughId =
          await database.peopleDao.createPersonByName(justLongEnough);
      expect(justLongEnoughId, isNonNegative);

      const justShortEnough =
          '01234567890123456789012345678901234567890123456789012345678901234567890123456789';
      final justShortEnoughId =
          await database.peopleDao.createPersonByName(justShortEnough);
      expect(justShortEnoughId, isNonNegative);

      const tooLong =
          '012345678901234567890123456789012345678901234567890123456789012345678901234567890';
      expect(
        () => database.peopleDao.createPersonByName(tooLong),
        throwsA(isA<InvalidDataException>()),
      );
    });

    test('person can be safely created by name', () async {
      const personName = 'Alice';
      final id = await database.peopleDao.createPersonByNameSafe(personName);
      expect(id, isNonNegative);
      final person = await database.peopleDao.getPersonById(id);
      expect(person?.name, personName);

      final anotherId =
          await database.peopleDao.createPersonByNameSafe(personName);
      expect(anotherId, id);
    });

    test('person can be updated', () async {
      const personName = 'Alice';
      final id = await database.peopleDao.createPersonByName(personName);
      expect(id, isNonNegative);
      final person = await database.peopleDao.getPersonById(id);
      expect(person?.name, personName);

      const newPersonName = 'Bob';
      final updateSuccessful = await database.peopleDao.updatePerson(
        person!.toCompanion(false).copyWith(name: const Value(newPersonName)),
      );
      expect(updateSuccessful, true);
      final updatedPersonById = await database.peopleDao.getPersonById(id);
      expect(updatedPersonById?.name, newPersonName);
      final updatedPersonByName =
          await database.peopleDao.getPersonByName(newPersonName);
      expect(updatedPersonByName?.id, id);
    });

    test('person can be deleted', () async {
      const personName = 'Alice';
      final id = await database.peopleDao.createPersonByName(personName);
      expect(id, isNonNegative);
      final person = await database.peopleDao.getPersonById(id);
      expect(person?.name, personName);

      await database.peopleDao.deletePerson(person!);
      final deletedPersonById = await database.peopleDao.getPersonById(id);
      expect(deletedPersonById, isNull);
      final deletedPersonByName =
          await database.peopleDao.getPersonByName(personName);
      expect(deletedPersonByName, isNull);
    });

    test('people stream emits alphabetically ordered people', () async {
      const personName = 'Alice';
      const anotherPersonName = 'Bob';
      await database.peopleDao.createPersonByName(personName);
      final expectation = expectLater(
          database.peopleDao
              .watchPeople()
              .map((people) => people.map((person) => person.name)),
          emitsInOrder([
            [personName],
            [personName, anotherPersonName],
          ]));
      await database.peopleDao.createPersonByName(anotherPersonName);
      await expectation;
    });

    test('people stream can be filtered by name', () async {
      const personName1 = 'Alice';
      const personName2 = 'Bob';
      const personName3 = 'Alex';
      await database.peopleDao.createPersonByName(personName1);
      final expectation = expectLater(
        database.peopleDao
            .watchPeople(nameFilter: 'Al')
            .map((people) => people.map((person) => person.name)),
        emitsInOrder([
          [personName1],
          [personName1],
          [personName3, personName1],
        ]),
      );
      await database.peopleDao.createPersonByName(personName2);
      await database.peopleDao.createPersonByName(personName3);
      await expectation;
    });
  });

  group('Items', () {
    test('item can be created and retrieved by id', () async {
      const itemName = 'Nineteen Eighty-Four';
      final id = await database.itemsDao.createItem(
        ItemsCompanion.insert(name: itemName),
      );
      expect(id, isNonNegative);
      final item = await database.itemsDao.getItemById(id);
      expect(item, isNotNull);
      expect(item!.name, itemName);
      expect(item.categoryId, isNull);

      const categoryName = 'Book';
      final categoryId = await database.categoriesDao.createCategoryByName(
        categoryName,
      );
      final anotherId = await database.itemsDao.createItem(
        ItemsCompanion.insert(name: itemName, categoryId: Value(categoryId)),
      );
      expect(anotherId, isNonNegative);
      final anotherItem = await database.itemsDao.getItemById(anotherId);
      expect(anotherItem, isNotNull);
      expect(anotherItem!.name, itemName);
      expect(anotherItem.categoryId, categoryId);
    });

    test('item with category can be created and retrieved', () async {
      const itemName = 'Nineteen Eighty-Four';
      const categoryName = 'Book';
      final id = await database.itemsDao.createItemWithCategory(
        itemName: itemName,
        categoryName: categoryName,
      );
      expect(id, isNonNegative);
      final itemWithCategoryById =
          await database.itemsDao.getItemWithCategoryById(id);
      expect(itemWithCategoryById, isNotNull);
      expect(itemWithCategoryById!.item.id, id);
      expect(itemWithCategoryById.item.name, itemName);
      expect(itemWithCategoryById.category?.name, categoryName);

      final itemWithCategoryByNames = await database.itemsDao
          .getItemWithCategoryByNames(itemName, categoryName);
      expect(itemWithCategoryByNames, isNotNull);
      expect(itemWithCategoryByNames!.item.id, id);
      expect(itemWithCategoryByNames.item.name, itemName);
      expect(itemWithCategoryByNames.category?.name, categoryName);

      final anotherId = await database.itemsDao.createItemWithCategory(
        itemName: itemName,
      );
      expect(anotherId, isNonNegative);
      final anotherItemWithCategory =
          await database.itemsDao.getItemWithCategoryByNames(itemName);
      expect(anotherItemWithCategory, isNotNull);
      expect(anotherItemWithCategory!.item.id, anotherId);
      expect(anotherItemWithCategory.item.name, itemName);
      expect(anotherItemWithCategory.category, isNull);
    });

    test('item name and category combinations must be unique', () async {
      const itemName = 'Nineteen Eighty-Four';
      const categoryName = 'Book';
      final id1 = await database.itemsDao.createItemWithCategory(
        itemName: itemName,
        categoryName: categoryName,
      );
      expect(id1, isNonNegative);
      // SqliteException(2067): UNIQUE constraint failed
      expect(
        () => database.itemsDao.createItemWithCategory(
          itemName: itemName,
          categoryName: categoryName,
        ),
        throwsA(isA<SqliteException>()),
      );

      const anotherCategoryName = 'DVD';
      final id2 = await database.itemsDao.createItemWithCategory(
        itemName: itemName,
        categoryName: anotherCategoryName,
      );
      expect(id2, isNonNegative);
      // SqliteException(2067): UNIQUE constraint failed
      expect(
        () => database.itemsDao.createItemWithCategory(
          itemName: itemName,
          categoryName: anotherCategoryName,
        ),
        throwsA(isA<SqliteException>()),
      );

      final id3 =
          await database.itemsDao.createItemWithCategory(itemName: itemName);
      expect(id3, isNonNegative);
      // SqliteException(2067): UNIQUE constraint failed
      expect(
        () => database.itemsDao.createItemWithCategory(itemName: itemName),
        throwsA(isA<SqliteException>()),
      );
    });

    test('item name must be between 1 and 80 characters long', () async {
      const tooShort = '';
      expect(
        () => database.itemsDao.createItemWithCategory(itemName: tooShort),
        throwsA(isA<InvalidDataException>()),
      );

      const justLongEnough = '0';
      final justLongEnoughId = await database.itemsDao
          .createItemWithCategory(itemName: justLongEnough);
      expect(justLongEnoughId, isNonNegative);

      const justShortEnough =
          '01234567890123456789012345678901234567890123456789012345678901234567890123456789';
      final justShortEnoughId = await database.itemsDao
          .createItemWithCategory(itemName: justShortEnough);
      expect(justShortEnoughId, isNonNegative);

      const tooLong =
          '012345678901234567890123456789012345678901234567890123456789012345678901234567890';
      expect(
        () => database.itemsDao.createItemWithCategory(itemName: tooLong),
        throwsA(isA<InvalidDataException>()),
      );
    });

    test('item with category can be safely created by names', () async {
      const itemName = 'Nineteen Eighty-Four';
      const categoryName = 'Book';
      final id = await database.itemsDao.createItemWithCategorySafe(
        itemName: itemName,
        categoryName: categoryName,
      );
      expect(id, isNonNegative);
      final itemWithCategory =
          await database.itemsDao.getItemWithCategoryById(id);
      expect(itemWithCategory, isNotNull);
      expect(itemWithCategory!.item.id, id);
      expect(itemWithCategory.item.name, itemName);
      expect(itemWithCategory.category?.name, categoryName);

      final anotherId = await database.itemsDao.createItemWithCategorySafe(
        itemName: itemName,
        categoryName: categoryName,
      );
      expect(anotherId, id);
    });

    test('item can be updated', () async {
      const itemName = 'Nineteen Eighty-Four';
      final id =
          await database.itemsDao.createItemWithCategory(itemName: itemName);
      expect(id, isNonNegative);
      final item = await database.itemsDao.getItemById(id);
      expect(item, isNotNull);
      expect(item!.name, itemName);
      expect(item.categoryId, isNull);

      const anotherItemName = 'Fight Club';
      const categoryName = 'DVD';
      final categoryId = await database.categoriesDao.createCategoryByName(
        categoryName,
      );
      final updateSuccessful = await database.itemsDao.updateItem(
        item.toCompanion(false).copyWith(
              name: const Value(anotherItemName),
              categoryId: Value(categoryId),
            ),
      );
      expect(updateSuccessful, true);
      final updatedItemBy = await database.itemsDao.getItemById(id);
      expect(updatedItemBy, isNotNull);
      expect(updatedItemBy!.name, anotherItemName);
      expect(updatedItemBy.categoryId, categoryId);
    });

    test('item can be deleted', () async {
      const itemName = 'Nineteen Eighty-Four';
      const categoryName = 'Book';
      final id = await database.itemsDao.createItemWithCategory(
        itemName: itemName,
        categoryName: categoryName,
      );
      expect(id, isNonNegative);
      final item = await database.itemsDao.getItemById(id);
      expect(item?.name, itemName);

      await database.itemsDao.deleteItem(item!);
      final deletedItemById = await database.itemsDao.getItemById(id);
      expect(deletedItemById, isNull);
      final deletedItemByNames = await database.itemsDao
          .getItemWithCategoryByNames(itemName, categoryName);
      expect(deletedItemByNames, isNull);

      const anotherItemName = 'Fight Club';
      final anotherId = await database.itemsDao.createItemWithCategory(
        itemName: anotherItemName,
      );
      expect(anotherId, isNonNegative);
      final anotherItem = await database.itemsDao.getItemById(anotherId);
      expect(anotherItem?.name, anotherItemName);

      await database.itemsDao.deleteItem(anotherItem!);
      final deletedAnotherItem =
          await database.itemsDao.getItemWithCategoryByNames(anotherItemName);
      expect(deletedAnotherItem, isNull);
    });

    test('category of item cannot be deleted', () async {
      const itemName = 'Nineteen Eighty-Four';
      const categoryName = 'Book';
      final id = await database.itemsDao.createItemWithCategory(
        itemName: itemName,
        categoryName: categoryName,
      );
      expect(id, isNonNegative);
      final itemWithCategory =
          await database.itemsDao.getItemWithCategoryById(id);
      expect(itemWithCategory?.category?.id, isNonNegative);

      // SqliteException(787): FOREIGN KEY constraint failed
      expect(
        () =>
            database.categoriesDao.deleteCategory(itemWithCategory!.category!),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
        'items with category stream emits alphabetically ordered items with category',
        () async {
      const itemName1 = 'Nineteen Eighty-Four';
      const categoryName1 = 'Book';
      const itemName2 = 'Fight Club';
      const categoryName2 = 'DVD';
      const item1String = '($itemName1, $categoryName1)';
      const item2String = '($itemName2, $categoryName1)';
      const item3String = '($itemName2, $categoryName2)';
      await database.itemsDao.createItemWithCategory(
        itemName: itemName1,
        categoryName: categoryName1,
      );
      // create category to avoid duplicate events
      await database.categoriesDao.createCategoryByName(categoryName2);
      final expectation = expectLater(
        database.itemsDao
            .watchItemsWithCategory()
            .map((itemsWithCategory) => itemsWithCategory.map(
                  (itemWithCategory) =>
                      '(${itemWithCategory.item.name}, ${itemWithCategory.category?.name})',
                )),
        emitsInOrder([
          [item1String],
          [item2String, item1String],
          [item2String, item3String, item1String],
        ]),
      );
      await database.itemsDao.createItemWithCategory(
        itemName: itemName2,
        categoryName: categoryName1,
      );
      await database.itemsDao.createItemWithCategory(
        itemName: itemName2,
        categoryName: categoryName2,
      );
      await expectation;
    });

    test('items with category stream can be filtered by name and categories',
        () async {
      const itemName1 = 'Nineteen Eighty-Four';
      const categoryName1 = 'Book';
      const itemName2 = 'Fight Club';
      const categoryName2 = 'Movie';
      const item1String = '($itemName1, $categoryName1)';
      const item2String = '($itemName1, ${null})';
      const item3String = '($itemName2, $categoryName1)';
      final categoryId =
          await database.categoriesDao.createCategoryByName(categoryName1);
      await database.itemsDao.createItemWithCategory(
        itemName: itemName1,
        categoryName: categoryName1,
      );
      final expectationFilteredName = expectLater(
        database.itemsDao
            .watchItemsWithCategory(nameFilter: 'y-')
            .map((itemsWithCategory) => itemsWithCategory.map(
                  (itemWithCategory) =>
                      '(${itemWithCategory.item.name}, ${itemWithCategory.category?.name})',
                )),
        emitsInOrder([
          [item1String],
          [item2String, item1String],
          [item2String, item1String],
          [item2String, item1String],
        ]),
      );
      final expectationFilteredCategory = expectLater(
        database.itemsDao.watchItemsWithCategory(categoriesFilter: [
          categoryId
        ]).map((itemsWithCategory) => itemsWithCategory.map(
              (itemWithCategory) =>
                  '(${itemWithCategory.item.name}, ${itemWithCategory.category?.name})',
            )),
        emitsInOrder([
          [item1String],
          [item1String],
          [item3String, item1String],
          [item3String, item1String],
        ]),
      );
      await database.itemsDao.createItemWithCategory(
        itemName: itemName1,
      );
      await database.itemsDao.createItemWithCategory(
        itemName: itemName2,
        categoryName: categoryName1,
      );
      await database.itemsDao.createItemWithCategory(
        itemName: itemName2,
        categoryName: categoryName2,
      );
      await expectationFilteredName;
      await expectationFilteredCategory;
    });
  });

  group('Lendings', () {
    test('lending can be created and retrieved by id', () async {
      const itemName = 'Nineteen Eighty-Four';
      final itemId =
          await database.itemsDao.createItemWithCategory(itemName: itemName);
      expect(itemId, isNonNegative);
      const personName = 'Alice';
      final personId = await database.peopleDao.createPersonByName(personName);
      expect(personId, isNonNegative);
      final date = DateTime(1949, 6, 8);
      final id = await database.lendingsDao.createLending(
        LendingsCompanion.insert(
          itemId: itemId,
          personId: personId,
          date: date,
        ),
      );
      expect(id, isNonNegative);
      final lending = await database.lendingsDao.getLendingById(id);
      expect(lending, isNotNull);
      expect(lending!.itemId, itemId);
      expect(lending.personId, personId);
      expect(lending.date, date);
      expect(lending.returnDate, isNull);
      expect(lending.isBorrowed, false);

      const anotherItemName = 'Fight Club';
      final anotherItemId = await database.itemsDao
          .createItemWithCategory(itemName: anotherItemName);
      expect(anotherItemId, isNonNegative);
      const anotherPersonName = 'Bob';
      final anotherPersonId =
          await database.peopleDao.createPersonByName(anotherPersonName);
      expect(anotherPersonId, isNonNegative);
      final anotherDate = DateTime(1996, 8, 17);
      final returnDate = DateTime(1999, 9, 10);
      final anotherId = await database.lendingsDao.createLending(
        LendingsCompanion.insert(
          itemId: anotherItemId,
          personId: anotherPersonId,
          date: anotherDate,
          returnDate: Value(returnDate),
          isBorrowed: const Value(true),
        ),
      );
      expect(anotherId, isNonNegative);
      final anotherLending =
          await database.lendingsDao.getLendingById(anotherId);
      expect(anotherLending, isNotNull);
      expect(anotherLending!.itemId, anotherItemId);
      expect(anotherLending.personId, anotherPersonId);
      expect(anotherLending.date, anotherDate);
      expect(anotherLending.returnDate, returnDate);
      expect(anotherLending.isBorrowed, true);
    });

    test('lending with data can be created and retrieved', () async {
      const itemName = 'Nineteen Eighty-Four';
      const categoryName = 'Book';
      const personName = 'Alice';
      final date = DateTime(1949, 6, 8);
      final returnDate = DateTime(1984, 10, 10);
      final id = await database.lendingsDao.createLendingWithData(
        itemName: itemName,
        categoryName: categoryName,
        personName: personName,
        date: date,
        returnDate: returnDate,
        isBorrowed: true,
      );
      expect(id, isNonNegative);
      final lendingWithData =
          await database.lendingsDao.getLendingWithDataById(id);
      expect(lendingWithData, isNotNull);
      expect(lendingWithData!.lending.id, id);
      expect(lendingWithData.lending.date, date);
      expect(lendingWithData.lending.returnDate, returnDate);
      expect(lendingWithData.lending.isBorrowed, true);
      expect(lendingWithData.item.name, itemName);
      expect(lendingWithData.category?.name, categoryName);
      expect(lendingWithData.person.name, personName);
    });

    test('lending can be updated', () async {
      const itemName = 'Nineteen Eighty-Four';
      final itemId =
          await database.itemsDao.createItemWithCategory(itemName: itemName);
      expect(itemId, isNonNegative);
      const personName = 'Alice';
      final personId = await database.peopleDao.createPersonByName(personName);
      expect(personId, isNonNegative);
      final date = DateTime(1949, 6, 8);
      final id = await database.lendingsDao.createLending(
        LendingsCompanion.insert(
          itemId: itemId,
          personId: personId,
          date: date,
        ),
      );
      expect(id, isNonNegative);
      final lending = await database.lendingsDao.getLendingById(id);
      expect(lending, isNotNull);
      expect(lending, isNotNull);
      expect(lending!.itemId, itemId);
      expect(lending.personId, personId);
      expect(lending.date, date);
      expect(lending.returnDate, isNull);
      expect(lending.isBorrowed, false);

      const anotherItemName = 'Fight Club';
      final anotherItemId = await database.itemsDao
          .createItemWithCategory(itemName: anotherItemName);
      expect(anotherItemId, isNonNegative);
      const anotherPersonName = 'Bob';
      final anotherPersonId =
          await database.peopleDao.createPersonByName(anotherPersonName);
      expect(anotherPersonId, isNonNegative);
      final anotherDate = DateTime(1996, 8, 17);
      final returnDate = DateTime(1999, 9, 10);
      final updateSuccessful = await database.lendingsDao.updateLending(
        lending.toCompanion(false).copyWith(
              itemId: Value(anotherItemId),
              personId: Value(anotherPersonId),
              date: Value(anotherDate),
              returnDate: Value(returnDate),
              isBorrowed: const Value(true),
            ),
      );
      expect(updateSuccessful, true);
      final updatedLending = await database.lendingsDao.getLendingById(id);
      expect(updatedLending, isNotNull);
      expect(updatedLending!.itemId, anotherItemId);
      expect(updatedLending.personId, anotherPersonId);
      expect(updatedLending.date, anotherDate);
      expect(updatedLending.returnDate, returnDate);
      expect(updatedLending.isBorrowed, true);
    });

    test('lending can be deleted', () async {
      const itemName = 'Nineteen Eighty-Four';
      final itemId =
          await database.itemsDao.createItemWithCategory(itemName: itemName);
      expect(itemId, isNonNegative);
      const personName = 'Alice';
      final personId = await database.peopleDao.createPersonByName(personName);
      expect(personId, isNonNegative);
      final date = DateTime(1949, 6, 8);
      final id = await database.lendingsDao.createLending(
        LendingsCompanion.insert(
          itemId: itemId,
          personId: personId,
          date: date,
        ),
      );
      expect(id, isNonNegative);
      final lending = await database.lendingsDao.getLendingById(id);
      expect(lending, isNotNull);

      await database.lendingsDao.deleteLending(lending!);
      final deletedLending = await database.lendingsDao.getLendingById(id);
      expect(deletedLending, isNull);
    });

    test('item and person of lending cannot be deleted', () async {
      const itemName = 'Nineteen Eighty-Four';
      const personName = 'Alice';
      final date = DateTime(1949, 6, 8);
      final id = await database.lendingsDao.createLendingWithData(
        itemName: itemName,
        personName: personName,
        date: date,
      );
      expect(id, isNonNegative);
      final lendingWithData =
          await database.lendingsDao.getLendingWithDataById(id);
      expect(lendingWithData?.item.id, isNonNegative);
      // SqliteException(787): FOREIGN KEY constraint failed
      expect(
        () => database.itemsDao.deleteItem(lendingWithData!.item),
        throwsA(isA<SqliteException>()),
      );
      expect(lendingWithData?.person.id, isNonNegative);
      // SqliteException(787): FOREIGN KEY constraint failed
      expect(
        () => database.peopleDao.deletePerson(lendingWithData!.person),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
        'lendings with data stream emits chronologically descending ordered lendings with data',
        () async {
      const itemName1 = 'Nineteen Eighty-Four';
      const personName1 = 'Alice';
      const itemName2 = 'Fight Club';
      const personName2 = 'Bob';
      final date1 = DateTime(1949, 6, 8);
      final date2 = DateTime(1996, 8, 17);
      final date3 = DateTime(1999, 9, 10);
      final lending1String = '($itemName1, $personName1, $date1)';
      final lending2String = '($itemName2, $personName2, $date3)';
      final lending3String = '($itemName2, $personName1, $date2)';
      await database.lendingsDao.createLendingWithData(
        itemName: itemName1,
        personName: personName1,
        date: date1,
      );
      // create item and person to avoid duplicate events
      await database.itemsDao.createItemWithCategory(itemName: itemName2);
      await database.peopleDao.createPersonByName(personName2);
      final expectation = expectLater(
        database.lendingsDao
            .watchLendingsWithData()
            .map((lendingsWithData) => lendingsWithData.map(
                  (lendingWithData) =>
                      '(${lendingWithData.item.name}, ${lendingWithData.person.name}, ${lendingWithData.lending.date})',
                )),
        emitsInOrder([
          [lending1String],
          [lending2String, lending1String],
          [lending2String, lending3String, lending1String],
        ]),
      );
      await database.lendingsDao.createLendingWithData(
        itemName: itemName2,
        personName: personName2,
        date: date3,
      );
      await database.lendingsDao.createLendingWithData(
        itemName: itemName2,
        personName: personName1,
        date: date2,
      );
      await expectation;
    });

    test(
        'lendings with data stream can be filtered by item name, item categories, and people',
        () async {
      const itemName1 = 'Nineteen Eighty-Four';
      const categoryName = 'Book';
      final categoryId =
          await database.categoriesDao.createCategoryByName(categoryName);
      const personName1 = 'Alice';
      final person1Id =
          await database.peopleDao.createPersonByName(personName1);
      const itemName2 = 'Fight Club';
      const personName2 = 'Bob';
      final date1 = DateTime(1949, 6, 8);
      final date2 = DateTime(1996, 8, 17);
      final date3 = DateTime(1999, 9, 10);

      String _stringFrom({
        required String itemName,
        String? categoryName,
        required String personName,
        required DateTime date,
        DateTime? returnDate,
        bool isBorrowed = false,
      }) =>
          '($itemName (${categoryName ?? 'None'}), $personName, $date, $returnDate, $isBorrowed)';
      String _stringFromLendingWithData(LendingWithData lendingWithData) =>
          _stringFrom(
            itemName: lendingWithData.item.name,
            categoryName: lendingWithData.category?.name,
            personName: lendingWithData.person.name,
            date: lendingWithData.lending.date,
            returnDate: lendingWithData.lending.returnDate,
            isBorrowed: lendingWithData.lending.isBorrowed,
          );

      final lending1String = _stringFrom(
        itemName: itemName1,
        categoryName: categoryName,
        personName: personName1,
        date: date1,
      );
      final lending2String = _stringFrom(
        itemName: itemName2,
        personName: personName1,
        date: date3,
        isBorrowed: true,
      );
      final lending3String = _stringFrom(
        itemName: itemName2,
        categoryName: categoryName,
        personName: personName2,
        date: date2,
        returnDate: date3,
      );

      await database.lendingsDao.createLendingWithData(
        itemName: itemName1,
        categoryName: categoryName,
        personName: personName1,
        date: date1,
      );
      // create item and person to avoid duplicate events
      await database.itemsDao.createItemWithCategory(itemName: itemName2);
      await database.itemsDao.createItemWithCategory(
          itemName: itemName2, categoryName: categoryName);
      await database.peopleDao.createPersonByName(personName2);

      final expectationFilteredName = expectLater(
        database.lendingsDao
            .watchLendingsWithData(itemFilter: 'Clu')
            .map((lendingsWithData) => lendingsWithData.map(
                  (lendingWithData) =>
                      _stringFromLendingWithData(lendingWithData),
                )),
        emitsInOrder([
          [],
          [lending2String],
          [lending2String, lending3String],
        ]),
      );
      final expectationFilteredCategory = expectLater(
        database.lendingsDao.watchLendingsWithData(
          categoriesFilter: [categoryId],
        ).map((lendingsWithData) => lendingsWithData.map(
              (lendingWithData) => _stringFromLendingWithData(lendingWithData),
            )),
        emitsInOrder([
          [lending1String],
          [lending1String],
          [lending3String, lending1String],
        ]),
      );
      final expectationFilteredPerson = expectLater(
        database.lendingsDao.watchLendingsWithData(
          peopleFilter: [person1Id],
        ).map((lendingsWithData) => lendingsWithData.map(
              (lendingWithData) => _stringFromLendingWithData(lendingWithData),
            )),
        emitsInOrder([
          [lending1String],
          [lending2String, lending1String],
          [lending2String, lending1String],
        ]),
      );
      final expectationFilteredBorrowed = expectLater(
        database.lendingsDao
            .watchLendingsWithData(
              borrowedFilter: true,
            )
            .map((lendingsWithData) => lendingsWithData.map(
                  (lendingWithData) =>
                      _stringFromLendingWithData(lendingWithData),
                )),
        emitsInOrder([
          [],
          [lending2String],
          [lending2String],
        ]),
      );
      final expectationFilteredReturned = expectLater(
        database.lendingsDao
            .watchLendingsWithData(
              returnedFilter: false,
            )
            .map((lendingsWithData) => lendingsWithData.map(
                  (lendingWithData) =>
                      _stringFromLendingWithData(lendingWithData),
                )),
        emitsInOrder([
          [lending1String],
          [lending2String, lending1String],
          [lending2String, lending1String],
        ]),
      );
      await database.lendingsDao.createLendingWithData(
        itemName: itemName2,
        personName: personName1,
        date: date3,
        isBorrowed: true,
      );
      await database.lendingsDao.createLendingWithData(
        itemName: itemName2,
        categoryName: categoryName,
        personName: personName2,
        date: date2,
        returnDate: date3,
      );
      await expectationFilteredName;
      await expectationFilteredCategory;
      await expectationFilteredPerson;
      await expectationFilteredBorrowed;
      await expectationFilteredReturned;
    });
  });
}
