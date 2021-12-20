import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../database/database.dart';

part 'lendings_filter_cubit.freezed.dart';

part 'lendings_filter_state.dart';

enum LendingsStatus { all, returned, notReturned }

enum LendingsType { all, lent, borrowed }

class LendingsFilterCubit extends Cubit<LendingsFilterState> {
  LendingsFilterCubit() : super(const LendingsFilterState());

  void clearAll() => emit(const LendingsFilterState());

  void clearCategories() => emit(state.copyWith(categories: const []));

  void clearPeople() => emit(state.copyWith(people: const []));

  void selectCategory(Category category, bool value) {
    if (value) {
      if (!state.categories.contains(category)) {
        emit(state.copyWith(categories: [...state.categories, category]));
      }
    } else {
      emit(state.copyWith(
        categories: state.categories.whereNot((c) => c == category).toList(),
      ));
    }
  }

  void selectPerson(Person person, bool value) {
    if (value) {
      if (!state.people.contains(person)) {
        emit(state.copyWith(people: [...state.people, person]));
      }
    } else {
      emit(state.copyWith(
        people: state.people.whereNot((p) => p == person).toList(),
      ));
    }
  }

  void selectStatus(LendingsStatus status, bool value) {
    if (value) {
      emit(state.copyWith(status: status));
    }
  }

  void selectType(LendingsType type, bool value) {
    if (value) {
      emit(state.copyWith(type: type));
    }
  }
}
