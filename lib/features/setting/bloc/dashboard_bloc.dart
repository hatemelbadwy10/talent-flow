import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardInitial()) {
    on<DashboardRequested>(_onRequested);
  }

  final DashboardRepository _repository;

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await _repository.getProfileDashboard();
    result.fold(
      (failure) => emit(DashboardFailed(failure.error)),
      (dashboard) => emit(DashboardLoaded(dashboard)),
    );
  }
}
