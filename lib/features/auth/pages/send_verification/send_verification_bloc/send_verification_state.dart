sealed class SendVerificationState {
  const SendVerificationState();
}

final class SendVerificationInitial extends SendVerificationState {
  const SendVerificationInitial();
}

final class SendVerificationLoading extends SendVerificationState {
  const SendVerificationLoading();
}

final class SendVerificationSucceeded extends SendVerificationState {
  const SendVerificationSucceeded({
    required this.identifier,
    required this.message,
  });

  final String identifier;
  final String message;
}

final class SendVerificationFailed extends SendVerificationState {
  const SendVerificationFailed(this.message);

  final String message;
}
