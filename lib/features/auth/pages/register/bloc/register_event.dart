import '../model/register_request.dart';

sealed class RegisterEvent {
  const RegisterEvent();
}

final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted(this.request);

  final RegisterRequest request;
}
