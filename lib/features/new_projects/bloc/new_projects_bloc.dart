
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/features/new_projects/repo/new_projects_repo.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/styles.dart';
import '../../projects/model/my_projects_model.dart';

class NewProjectsBloc extends Bloc<AppEvent, AppState> {

  final NewProjectsRepo _projectsRepo;

  NewProjectsBloc(this._projectsRepo) : super(Start()) {
    on<Add>(_onGetProjects);
    on<Click>(_onClick);
    on<Update>(_onAddFavorite);
  }

  Future<void> _onGetProjects(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final result = await _projectsRepo.getProjects();
      result.fold(
            (failure) => emit(Error()),
            (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }

          final List<MyProjectsModel> projects =
          (response.data['payload'] as List)
              .map((e) => MyProjectsModel.fromJson(e))
              .toList();

          emit(Done(list: projects));
        },
      );
    } catch (_) {
      emit(Error());
    }
  }

  Future<void> _onClick(Click event, Emitter<AppState> emit) async {
    emit(Loading());

    try {
      final args = event.arguments as Map<String, dynamic>;
      final projectId = args["projectId"] as int;
      final description = args["description"] as String;

      final result = await _projectsRepo.addOffer(projectId, description);

      result.fold(
            (failure) => emit(Error()),
            (response) => emit(Done()),
      );
    } catch (e) {
      emit(Error());
    }
  }
  Future<void> _onAddFavorite(Update event, Emitter<AppState> emit) async {
    // emit(Loading()); // You might want a specific loading state for favorite
    try {
      final projectId = event.arguments as int; // Assuming arguments is the project ID
      final result = await _projectsRepo.addRemoveFavorite(projectId);

      result.fold(
            (failure) {
              AppCore.showSnackBar(notification: AppNotification(
                message: "",
                backgroundColor: Styles.ACTIVE,
                borderColor: Styles.ACTIVE,
              ));
            }, // You might want a specific error state for favorite
            (response) {
              AppCore.showSnackBar(notification: AppNotification(
                message: response.data['message'],
                backgroundColor: Styles.ACTIVE,
                borderColor: Styles.ACTIVE,
              ));
            }, // You might want a specific done state for favorite
      );
    } catch (e) {
      emit(Error());
    }
  }
}
