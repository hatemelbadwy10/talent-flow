import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/auth_session_store.dart';
import '../model/confirm_code_request.dart';
import '../repo/confirm_code_repository.dart';
import 'confirm_code_event.dart';
import 'confirm_code_state.dart';

class ConfirmCodeBloc extends Bloc<ConfirmCodeEvent, ConfirmCodeState> {
  ConfirmCodeBloc({
    required ConfirmCodeRepository repository,
    required AuthSessionStore sessionStore,
  })  : _repository = repository,
        _sessionStore = sessionStore,
        super(const ConfirmCodeInitial()) {
    on<CodeSubmitted>(_onCodeSubmitted);
  }

  final ConfirmCodeRepository _repository;
  final AuthSessionStore _sessionStore;

  Future<void> _onCodeSubmitted(
    CodeSubmitted event,
    Emitter<ConfirmCodeState> emit,
  ) async {
    emit(const ConfirmCodeLoading());
    final result = await _repository.confirm(event.request);
    await result.fold(
      (failure) async => emit(ConfirmCodeFailed(failure.error)),
      (success) async {
        if (event.request.flow == ConfirmationFlow.registration) {
          final authResponse = success.authResponse;
          if (authResponse == null) {
            emit(const ConfirmCodeFailed('Authentication payload is missing'));
            return;
          }
          await _sessionStore.persistAuthenticatedSession(authResponse);
        }
        emit(ConfirmCodeSucceeded(
          request: event.request,
          message: success.message,
        ));
      },
    );
  }
}
