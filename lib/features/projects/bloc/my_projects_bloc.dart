import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/projects_repo.dart';
import 'my_projects_event.dart';
import 'my_projects_state.dart';

class MyProjectsBloc extends Bloc<MyProjectsEvent, MyProjectsState> {
  final ProjectsRepo _projectsRepo;

  MyProjectsBloc(this._projectsRepo) : super(const MyProjectsInitial()) {
    on<ProjectsRequested>(_onGetProjects);
    on<ProjectDetailsRequested>(_onGetSingleProject);
  }

  Future<void> _onGetProjects(
    ProjectsRequested event,
    Emitter<MyProjectsState> emit,
  ) async {
    emit(const MyProjectsLoading());
    try {
      final result = await _projectsRepo.getProjects(
        status: event.status,
        categoryId: event.categoryId,
      );

      result.fold(
        (failure) {
          log('MyProjectsBloc getProjects failure: ${failure.error}');
          emit(MyProjectsFailure(message: failure.error));
        },
        (projects) {
          emit(MyProjectsLoaded(projects));
        },
      );
    } catch (e) {
      log('Error in _onGetProjects: $e');
      emit(MyProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onGetSingleProject(
    ProjectDetailsRequested event,
    Emitter<MyProjectsState> emit,
  ) async {
    emit(const MyProjectsLoading());

    try {
      final result = await _projectsRepo.getSingleProject(event.projectId);
      result.fold(
        (failure) => emit(MyProjectsFailure(message: failure.error)),
        (project) => emit(ProjectDetailsLoaded(project)),
      );
    } catch (e, s) {
      log("Error in _onGetSingleProject: $e\n$s");
      emit(MyProjectsFailure(message: e.toString()));
    }
  }
}
