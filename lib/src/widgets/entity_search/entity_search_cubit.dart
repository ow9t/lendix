import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class EntitySearchCubit<T> extends Cubit<List<T>?> {
  EntitySearchCubit(this._stream) : super(null);

  final Stream<List<T>> Function(String query) _stream;
  StreamSubscription<List<T>>? subscription;

  void query(String query) {
    subscription?.cancel();
    subscription = _stream(query).listen((results) => emit(results));
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
