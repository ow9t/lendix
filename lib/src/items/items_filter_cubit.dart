import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

class ItemsFilterCubit extends Cubit<List<Category>> {
  ItemsFilterCubit() : super(const []);

  void clear() => emit(const []);

  void select(Category category, bool value) {
    if (value) {
      if (!state.contains(category)) {
        emit([...state, category]);
      }
    } else {
      emit(state.where((c) => c != category).toList());
    }
  }
}
