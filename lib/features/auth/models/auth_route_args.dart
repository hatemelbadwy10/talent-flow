import '../pages/confirm_code/model/confirm_code_request.dart';

final class ChangePasswordArgs {
  const ChangePasswordArgs({required this.identifier});

  final String identifier;

  factory ChangePasswordArgs.fromRoute(Object? value) {
    if (value is ChangePasswordArgs) {
      return value;
    }
    final map = value is Map ? value : const <Object?, Object?>{};
    return ChangePasswordArgs(
      identifier: map['identifier']?.toString() ?? '',
    );
  }
}

final class ConfirmCodeArgs {
  const ConfirmCodeArgs({
    required this.identifier,
    required this.flow,
  });

  final String identifier;
  final ConfirmationFlow flow;

  factory ConfirmCodeArgs.fromRoute(Object? value) {
    if (value is ConfirmCodeArgs) {
      return value;
    }
    final map = value is Map ? value : const <Object?, Object?>{};
    final flow = map['isPhoneVerification'] == true
        ? ConfirmationFlow.phoneVerification
        : map['isRegister'] == true
            ? ConfirmationFlow.registration
            : map['isFromLogin'] == true
                ? ConfirmationFlow.loginActivation
                : ConfirmationFlow.passwordReset;
    return ConfirmCodeArgs(
      identifier: (map['identifier'] ?? map['email'] ?? '').toString(),
      flow: flow,
    );
  }
}
