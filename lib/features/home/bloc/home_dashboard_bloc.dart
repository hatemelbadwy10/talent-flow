import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/home_dashboard_repository.dart';
import 'home_dashboard_event.dart';
import 'home_dashboard_state.dart';

class HomeDashboardBloc extends Bloc<HomeDashboardEvent, HomeDashboardState> {
  HomeDashboardBloc({required HomeDashboardRepository repository})
      : _repository = repository,
        super(const HomeDashboardInitial()) {
    on<HomeDashboardRequested>(_onRequested);
  }

  final HomeDashboardRepository _repository;

  Future<void> _onRequested(
    HomeDashboardRequested event,
    Emitter<HomeDashboardState> emit,
  ) async {
    emit(const HomeDashboardLoading());
    final result = await _repository.getDashboard();
    result.fold(
      (failure) => emit(HomeDashboardFailed(failure.error)),
      (dashboard) => emit(HomeDashboardLoaded(dashboard)),
    );
  }
}
