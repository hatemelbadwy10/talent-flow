enum ConfirmationFlow {
  registration,
  loginActivation,
  passwordReset,
  phoneVerification,
}

class ConfirmCodeRequest {
  const ConfirmCodeRequest({
    required this.identifier,
    required this.otp,
    required this.flow,
  });

  final String identifier;
  final String otp;
  final ConfirmationFlow flow;

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'otp': otp,
        if (flow == ConfirmationFlow.phoneVerification) 'is_phone': 'true',
      };
}
