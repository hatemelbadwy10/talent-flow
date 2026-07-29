import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/single_project_model.dart';
import '../repo/projects_repository.dart';

sealed class ProjectDetailsEvent {
  const ProjectDetailsEvent();
}

final class ProjectDetailsRequested extends ProjectDetailsEvent {
  const ProjectDetailsRequested(this.id);
  final int id;
}

sealed class ProjectDetailsState {
  const ProjectDetailsState();
}

final class ProjectDetailsInitial extends ProjectDetailsState {
  const ProjectDetailsInitial();
}

final class ProjectDetailsLoading extends ProjectDetailsState {
  const ProjectDetailsLoading();
}

final class ProjectDetailsLoaded extends ProjectDetailsState {
  const ProjectDetailsLoaded(this.project);
  final SingleProjectModel project;
}

final class ProjectDetailsFailed extends ProjectDetailsState {
  const ProjectDetailsFailed(this.message);
  final String message;
}

class ProjectDetailsBloc
    extends Bloc<ProjectDetailsEvent, ProjectDetailsState> {
  ProjectDetailsBloc({required ProjectsRepository repository})
      : _repository = repository,
        super(const ProjectDetailsInitial()) {
    on<ProjectDetailsRequested>(_onRequested);
  }

  final ProjectsRepository _repository;

  Future<void> _onRequested(
    ProjectDetailsRequested event,
    Emitter<ProjectDetailsState> emit,
  ) async {
    emit(const ProjectDetailsLoading());
    final result = await _repository.getProjectDetails(event.id);
    result.fold(
      (failure) => emit(ProjectDetailsFailed(failure.error)),
      (project) => emit(ProjectDetailsLoaded(project)),
    );
  }
}
