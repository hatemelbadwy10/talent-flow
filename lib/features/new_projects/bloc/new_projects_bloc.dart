import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/features/new_projects/repo/new_projects_repo.dart';

import '../../../app/core/styles.dart';
import 'new_projects_event.dart';
import 'new_projects_state.dart';

class NewProjectsBloc extends Bloc<NewProjectsEvent, NewProjectsState> {
  final NewProjectsRepo _projectsRepo;

  NewProjectsBloc(this._projectsRepo) : super(const NewProjectsInitial()) {
    on<NewProjectsRequested>(_onGetProjects);
    on<ProjectOfferSubmitted>(_onSubmitOffer);
    on<ProjectFavouriteToggled>(_onAddFavorite);
  }

  Future<void> _onGetProjects(
    NewProjectsRequested event,
    Emitter<NewProjectsState> emit,
  ) async {
    emit(const NewProjectsLoading());
    try {
      final result = await _projectsRepo.getProjects();
      result.fold(
        (failure) => emit(NewProjectsFailure(message: failure.error)),
        (projects) => emit(NewProjectsLoaded(projects)),
      );
    } catch (_) {
      emit(const NewProjectsFailure());
    }
  }

  Future<void> _onSubmitOffer(
    ProjectOfferSubmitted event,
    Emitter<NewProjectsState> emit,
  ) async {
    emit(const OfferSubmissionInProgress());

    try {
      final result =
          await _projectsRepo.addOffer(event.projectId, event.description);

      result.fold(
        (failure) => emit(OfferSubmissionFailure(message: failure.error)),
        (message) => emit(OfferSubmissionSuccess(message: message)),
      );
    } catch (e) {
      emit(OfferSubmissionFailure(message: e.toString()));
    }
  }

  Future<void> _onAddFavorite(
    ProjectFavouriteToggled event,
    Emitter<NewProjectsState> emit,
  ) async {
    try {
      final result = await _projectsRepo.addRemoveFavorite(event.projectId);

      result.fold(
        (failure) {
          AppCore.showSnackBar(
              notification: AppNotification(
            message: failure.error,
            backgroundColor: Styles.ACTIVE,
            borderColor: Styles.ACTIVE,
          ));
        },
        (message) {
          AppCore.showSnackBar(
              notification: AppNotification(
            message: message ?? '',
            backgroundColor: Styles.ACTIVE,
            borderColor: Styles.ACTIVE,
          ));
        },
      );
    } catch (e) {
      emit(NewProjectsFailure(message: e.toString()));
    }
  }
}
