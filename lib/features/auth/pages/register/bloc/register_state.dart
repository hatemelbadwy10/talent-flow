sealed class RegisterState {
  const RegisterState();
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

final class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

final class RegisterSucceeded extends RegisterState {
  const RegisterSucceeded(this.email);

  final String email;
}

final class RegisterFailed extends RegisterState {
  const RegisterFailed(this.message);

  final String message;
}
