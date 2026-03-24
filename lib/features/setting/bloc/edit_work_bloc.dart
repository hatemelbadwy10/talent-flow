import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../model/edit_work_request_model.dart';
import '../repo/add_word_repo.dart';

class EditWorkBloc extends Bloc<AppEvent, AppState> {
  EditWorkBloc(this._repo) : super(Start()) {
    on<Update>(_onUpdateWork);
    on<Delete>(_onDeleteWork);
  }

  final AddWorkRepo _repo;

  Future<void> _onUpdateWork(Update event, Emitter<AppState> emit) async {
    final request = event.arguments;
    if (request is! EditWorkRequestModel) {
      emit(Error());
      return;
    }

    emit(Loading());
    final result = await _repo.updateWork(request: request);
    result.fold(
      (failure) {
        log('Edit work update error: ${failure.error}');
        emit(Error());
      },
      (_) => emit(Done(data: 'updated')),
    );
  }

  Future<void> _onDeleteWork(Delete event, Emitter<AppState> emit) async {
    final id = event.arguments;
    if (id is! int) {
      emit(Error());
      return;
    }

    emit(Loading());
    final result = await _repo.deleteWork(id);
    result.fold(
      (failure) {
        log('Edit work delete error: ${failure.error}');
        emit(Error());
      },
      (_) => emit(Done(data: 'deleted')),
    );
  }
}
