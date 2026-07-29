import '../model/confirm_code_request.dart';

sealed class ConfirmCodeEvent {
  const ConfirmCodeEvent();
}

final class CodeSubmitted extends ConfirmCodeEvent {
  const CodeSubmitted(this.request);

  final ConfirmCodeRequest request;
}
