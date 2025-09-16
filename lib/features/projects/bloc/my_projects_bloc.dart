import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import '../model/my_projects_model.dart';
import '../model/single_project_model.dart';
import '../repo/projects_repo.dart';

class MyProjectsBloc extends Bloc<AppEvent, AppState> {
  final ProjectsRepo _projectsRepo;

  MyProjectsBloc(this._projectsRepo) : super(Start()) {
    on<Add>(_onGetProjects);
    on<Click>(onClick);
  }

  Future<void> _onGetProjects(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      log('event.arguments ${event.arguments}');

      String? status;
      int? categoryId;

      if (event.arguments is String) {
        log('status ${event.arguments}');
        status = event.arguments as String?;
      } else if (event.arguments is int) {
        log('categoryId ${event.arguments}');
        categoryId = event.arguments as int?;
      }

      final result = await _projectsRepo.getProjects(
        status: status,
        categoryId: categoryId,
      );

      result.fold(
            (failure) {
          log('🔴 HomeBloc Error - Failure: ${failure.error}');
          emit(Error());
        },
            (response) {
          log("response ${response.data}");
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }
          final List<MyProjectsModel> projects;

          if (categoryId == null) {
            projects = (response.data['payload'] as List)
                .map((e) => MyProjectsModel.fromJson(e))
                .toList();
          } else {
            projects = (response.data['payload']['items'] as List)
                .map((e) => MyProjectsModel.fromJson(e))
                .toList();
          }

          emit(Done(list: projects));
        },
      );
    } catch (e) {
      log('🔴 Error in getProjects: $e');
      emit(Error());
    }
  }
  Future<void> onClick(Click event, Emitter<AppState> emit) async {
    emit(Loading());

    try {
      // ناخد الـ id من arguments
      final id = event.arguments as int;

      final result = await _projectsRepo.getSingleProject(id);
      result.fold(
            (failure) => emit(Error()),
            (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }

          final project = SingleProjectModel.fromJson(response.data['payload']);
          emit(Done(model: project)); // تقدر تمرره كـ object أو تعمل state مخصص
        },
      );
    } catch (e, s) {
      log("Error in getSingleProject: $e\n$s");
      emit(Error());
    }
  }
}
