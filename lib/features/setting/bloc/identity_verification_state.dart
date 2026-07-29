sealed class IdentityVerificationState {
  const IdentityVerificationState();
}

final class IdentityVerificationInitial extends IdentityVerificationState {
  const IdentityVerificationInitial();
}

final class IdentityVerificationSubmitting extends IdentityVerificationState {
  const IdentityVerificationSubmitting();
}

final class IdentityVerificationSucceeded extends IdentityVerificationState {
  const IdentityVerificationSucceeded(this.message);
  final String message;
}

final class IdentityVerificationFailed extends IdentityVerificationState {
  const IdentityVerificationFailed(this.message);
  final String message;
}
