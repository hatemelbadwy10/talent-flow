import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/new_projects_repository.dart';
import 'new_projects_event.dart';
import 'new_projects_state.dart';

class NewProjectsBloc extends Bloc<NewProjectsEvent, NewProjectsState> {
  NewProjectsBloc({required NewProjectsRepository repository})
      : _repository = repository,
        super(const NewProjectsInitial()) {
    on<ProjectFeedRequested>(_onFeedRequested);
    on<OfferSubmitted>(_onOfferSubmitted);
    on<ProjectFavoriteToggled>(_onFavoriteToggled);
  }

  final NewProjectsRepository _repository;

  Future<void> _onFeedRequested(
    ProjectFeedRequested event,
    Emitter<NewProjectsState> emit,
  ) async {
    emit(const ProjectFeedLoading());
    final result = await _repository.getProjectFeed(
      specializationId: event.specializationId,
      sortBy: event.sortBy,
      search: event.search,
    );
    result.fold(
      (failure) => emit(ProjectFeedFailed(failure.error)),
      (projects) => emit(ProjectFeedLoaded(projects)),
    );
  }

  Future<void> _onOfferSubmitted(
    OfferSubmitted event,
    Emitter<NewProjectsState> emit,
  ) async {
    emit(const OfferSubmitting());
    final result = await _repository.submitOffer(
      projectId: event.projectId,
      description: event.description,
      answers: event.answers,
      proposalId: event.proposalId,
    );
    result.fold(
      (failure) => emit(OfferSubmissionFailed(failure.error)),
      (message) => emit(OfferSubmissionSucceeded(message)),
    );
  }

  Future<void> _onFavoriteToggled(
    ProjectFavoriteToggled event,
    Emitter<NewProjectsState> emit,
  ) async {
    final result = await _repository.toggleProjectFavorite(event.projectId);
    result.fold(
      (failure) => emit(ProjectFavoriteFailed(
        projectId: event.projectId,
        message: failure.error,
      )),
      (message) => emit(ProjectFavoriteSucceeded(
        projectId: event.projectId,
        message: message,
      )),
    );
  }
}
