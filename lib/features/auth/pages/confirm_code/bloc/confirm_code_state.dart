import '../model/confirm_code_request.dart';

sealed class ConfirmCodeState {
  const ConfirmCodeState();
}

final class ConfirmCodeInitial extends ConfirmCodeState {
  const ConfirmCodeInitial();
}

final class ConfirmCodeLoading extends ConfirmCodeState {
  const ConfirmCodeLoading();
}

final class ConfirmCodeSucceeded extends ConfirmCodeState {
  const ConfirmCodeSucceeded({
    required this.request,
    required this.message,
  });

  final ConfirmCodeRequest request;
  final String message;
}

final class ConfirmCodeFailed extends ConfirmCodeState {
  const ConfirmCodeFailed(this.message);

  final String message;
}
