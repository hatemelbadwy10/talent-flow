import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/projects_repository.dart';
import 'my_projects_event.dart';
import 'my_projects_state.dart';

class MyProjectsBloc extends Bloc<MyProjectsEvent, MyProjectsState> {
  MyProjectsBloc({required ProjectsRepository repository})
      : _repository = repository,
        super(const MyProjectsInitial()) {
    on<MyProjectsRequested>(_onRequested);
  }

  final ProjectsRepository _repository;

  Future<void> _onRequested(
    MyProjectsRequested event,
    Emitter<MyProjectsState> emit,
  ) async {
    emit(const MyProjectsLoading());
    final result = await _repository.getProjectList(
      status: event.status,
      categoryId: event.categoryId,
    );
    result.fold(
      (failure) => emit(MyProjectsFailed(failure.error)),
      (projects) => emit(MyProjectsLoaded(projects)),
    );
  }
}
