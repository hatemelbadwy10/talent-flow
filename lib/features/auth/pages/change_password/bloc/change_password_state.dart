sealed class ChangePasswordState {
  const ChangePasswordState();
}

final class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

final class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();
}

final class ChangePasswordSucceeded extends ChangePasswordState {
  const ChangePasswordSucceeded(this.message);
  final String message;
}

final class ChangePasswordFailed extends ChangePasswordState {
  const ChangePasswordFailed(this.message);
  final String message;
}
