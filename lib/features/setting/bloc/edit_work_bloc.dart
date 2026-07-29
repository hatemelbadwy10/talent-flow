import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/edit_work_repository.dart';
import 'edit_work_event.dart';
import 'edit_work_state.dart';

class EditWorkBloc extends Bloc<EditWorkEvent, EditWorkState> {
  EditWorkBloc({required EditWorkRepository repository})
      : _repository = repository,
        super(const EditWorkInitial()) {
    on<WorkUpdateSubmitted>(_onUpdate);
    on<WorkDeleteSubmitted>(_onDelete);
  }

  final EditWorkRepository _repository;

  Future<void> _onUpdate(
    WorkUpdateSubmitted event,
    Emitter<EditWorkState> emit,
  ) async {
    emit(const EditWorkSubmitting());
    final result = await _repository.updateWork(request: event.request);
    result.fold(
      (failure) => emit(EditWorkFailed(failure.error)),
      (_) => emit(const EditWorkSucceeded(EditWorkAction.updated)),
    );
  }

  Future<void> _onDelete(
    WorkDeleteSubmitted event,
    Emitter<EditWorkState> emit,
  ) async {
    emit(const EditWorkSubmitting());
    final result = await _repository.deleteWork(event.workId);
    result.fold(
      (failure) => emit(EditWorkFailed(failure.error)),
      (_) => emit(const EditWorkSucceeded(EditWorkAction.deleted)),
    );
  }
}
