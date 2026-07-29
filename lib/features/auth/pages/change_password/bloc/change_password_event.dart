sealed class ChangePasswordEvent {
  const ChangePasswordEvent();
}

final class ChangePasswordSubmitted extends ChangePasswordEvent {
  const ChangePasswordSubmitted({
    required this.identifier,
    required this.password,
    required this.passwordConfirmation,
  });
  final String identifier;
  final String password;
  final String passwordConfirmation;
}
