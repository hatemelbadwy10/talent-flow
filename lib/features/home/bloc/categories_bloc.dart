import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/categories_repository.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc({required CategoriesRepository repository})
      : _repository = repository,
        super(const CategoriesInitial()) {
    on<CategoriesRequested>(_onRequested);
  }

  final CategoriesRepository _repository;

  Future<void> _onRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());
    final result = await _repository.getCategoryList();
    result.fold(
      (failure) => emit(CategoriesFailed(failure.error)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }
}
