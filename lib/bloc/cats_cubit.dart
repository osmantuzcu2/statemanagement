import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statemanagement/bloc/cats_repository.dart';

import 'cat.dart';
import 'cats_state.dart';

class CatsCubit extends Cubit<CatsState> {
  final CatsRepository _catsRepository;
  CatsCubit(this._catsRepository) : super(CatsInitial());
  List<Cat> cats;

  Future<void> getCats() async {
    try {
      emit(CatsLoading());
      await Future.delayed(Duration(milliseconds: 500));
      cats = await _catsRepository.getCats();
      emit(CatsCompleted(cats));
    } on NetworkError catch (e) {
      emit(CatsError(e.message));
    }
  }

  clearAll() {
    cats.clear();
    emit(CatsLoading());
    Future.delayed(Duration(milliseconds: 500));
    emit(CatsCompleted(cats));
  }

  addCat(Cat acat) {
    cats.add(acat);
    emit(CatsLoading());
    Future.delayed(Duration(milliseconds: 500));
    emit(CatsCompleted(cats));
  }
}
