import '../model/identity_verification_request.dart';

sealed class IdentityVerificationEvent {
  const IdentityVerificationEvent();
}

final class IdentityVerificationSubmitted extends IdentityVerificationEvent {
  const IdentityVerificationSubmitted(this.request);
  final IdentityVerificationRequest request;
}
