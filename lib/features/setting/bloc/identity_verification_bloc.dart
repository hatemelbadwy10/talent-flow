import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../model/identity_verification_request.dart';
import '../repo/settings_repo.dart';

class IdentityVerificationBloc extends Bloc<AppEvent, AppState> {
  IdentityVerificationBloc(this._settingsRepo) : super(Start()) {
    on<Add>(_onSubmitIdentityVerification);
  }

  final SettingsRepo _settingsRepo;

  Future<void> _onSubmitIdentityVerification(
    Add event,
    Emitter<AppState> emit,
  ) async {
    final request = event.arguments;
    if (request is! IdentityVerificationRequest) {
      emit(Error());
      return;
    }

    emit(Loading());
    try {
      final result = await _settingsRepo.submitIdentityVerification(request);
      result.fold(
        (failure) {
          log('Identity verification error: $failure');
          emit(Error());
        },
        (response) => emit(Done(data: response.data)),
      );
    } catch (e, s) {
      log('Identity verification exception', error: e, stackTrace: s);
      emit(Error());
    }
  }
}
