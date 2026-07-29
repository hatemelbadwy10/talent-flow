import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/change_password_repository.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc({required ChangePasswordRepository repository})
      : _repository = repository,
        super(const ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  final ChangePasswordRepository _repository;

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(const ChangePasswordLoading());
    final result = await _repository.changePassword(
      identifier: event.identifier,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );
    result.fold(
      (failure) => emit(ChangePasswordFailed(failure.error)),
      (message) => emit(ChangePasswordSucceeded(message)),
    );
  }
}
