sealed class SendVerificationEvent {
  const SendVerificationEvent();
}

final class VerificationRequested extends SendVerificationEvent {
  const VerificationRequested({required this.identifier});

  final String identifier;
}
