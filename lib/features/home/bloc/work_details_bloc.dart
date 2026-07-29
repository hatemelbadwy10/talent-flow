import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/work_details_model.dart';
import '../repo/work_details_repository.dart';

sealed class WorkDetailsEvent {
  const WorkDetailsEvent();
}

final class WorkDetailsRequested extends WorkDetailsEvent {
  const WorkDetailsRequested(this.id);
  final int id;
}

sealed class WorkDetailsState {
  const WorkDetailsState();
}

final class WorkDetailsInitial extends WorkDetailsState {
  const WorkDetailsInitial();
}

final class WorkDetailsLoading extends WorkDetailsState {
  const WorkDetailsLoading();
}

final class WorkDetailsLoaded extends WorkDetailsState {
  const WorkDetailsLoaded(this.work);
  final WorkDetailsModel work;
}

final class WorkDetailsFailed extends WorkDetailsState {
  const WorkDetailsFailed(this.message);
  final String message;
}

class WorkDetailsBloc extends Bloc<WorkDetailsEvent, WorkDetailsState> {
  WorkDetailsBloc({required WorkDetailsRepository repository})
      : _repository = repository,
        super(const WorkDetailsInitial()) {
    on<WorkDetailsRequested>(_onRequested);
  }

  final WorkDetailsRepository _repository;

  Future<void> _onRequested(
    WorkDetailsRequested event,
    Emitter<WorkDetailsState> emit,
  ) async {
    emit(const WorkDetailsLoading());
    final result = await _repository.getWork(event.id);
    result.fold(
      (failure) => emit(WorkDetailsFailed(failure.error)),
      (work) => emit(WorkDetailsLoaded(work)),
    );
  }
}
