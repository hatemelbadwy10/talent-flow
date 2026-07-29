import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/core/app_event.dart';
import '../../../data/auth_session_store.dart';
import '../repo/login_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

// Kept temporarily for RegisterBloc compatibility. Registration owns this
// event after its migration and this shim can then be removed.
final class SocialLoginClick extends AppEvent {
  SocialLoginClick({
    required this.provider,
    required this.token,
    this.userType,
  });

  final String provider;
  final String token;
  final String? userType;
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required LoginRepository repository,
    required AuthSessionStore sessionStore,
  })  : _repository = repository,
        _sessionStore = sessionStore,
        super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginRepository _repository;
  final AuthSessionStore _sessionStore;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _repository.logIn(
      email: event.email,
      password: event.password,
    );

    await result.fold(
      (failure) async {
        if (_isAccountUnverified(failure.error)) {
          await _repository.resendVerificationEmail(event.email);
          emit(LoginVerificationRequired(
            email: event.email,
            message: failure.error,
          ));
          return;
        }
        emit(LoginFailed(failure.error));
      },
      (response) async {
        await _sessionStore.saveCredentials(
          email: event.email,
          password: event.password,
        );
        await _sessionStore.persistAuthenticatedSession(response);
        emit(const LoginSucceeded());
      },
    );
  }

  bool _isAccountUnverified(String message) {
    final normalized = message.toLowerCase();
    return message.contains('قم بتأكيد الحساب') ||
        normalized.contains('verify') ||
        normalized.contains('confirm') ||
        normalized.contains('unverified');
  }
}
