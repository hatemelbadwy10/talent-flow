sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSucceeded extends LoginState {
  const LoginSucceeded();
}

final class LoginVerificationRequired extends LoginState {
  const LoginVerificationRequired({
    required this.email,
    required this.message,
  });

  final String email;
  final String message;
}

final class LoginFailed extends LoginState {
  const LoginFailed(this.message);

  final String message;
}
