part of 'lendings_filter_cubit.dart';

@freezed
class LendingsFilterState with _$LendingsFilterState {
  const LendingsFilterState._();

  const factory LendingsFilterState({
    @Default(LendingsStatus.all) LendingsStatus status,
    @Default(LendingsType.all) LendingsType type,
    @Default([]) List<Category> categories,
    @Default([]) List<Person> people,
  }) = _LendingsFilterState;

  bool get categoriesFiltered => categories.isNotEmpty;
  bool get peopleFiltered => people.isNotEmpty;
  bool get isFiltered =>
      status != LendingsStatus.all ||
      type != LendingsType.all ||
      categoriesFiltered ||
      peopleFiltered;
}
