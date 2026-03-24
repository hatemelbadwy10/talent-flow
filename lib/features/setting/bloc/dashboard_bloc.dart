import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../repo/dashboard_repo.dart';

class DashboardBloc extends Bloc<AppEvent, AppState> {
  DashboardBloc(this._repo) : super(Start()) {
    on<Add>(_onGetDashboard);
  }

  final DashboardRepo _repo;

  Future<void> _onGetDashboard(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final result = await _repo.getProfileDashboard();
      result.fold(
        (failure) {
          log('Dashboard error: $failure');
          emit(Error());
        },
        (response) {
          emit(Done(model: response));
        },
      );
    } catch (e, s) {
      log('Exception in DashboardBloc', error: e, stackTrace: s);
      emit(Error());
    }
  }
}
