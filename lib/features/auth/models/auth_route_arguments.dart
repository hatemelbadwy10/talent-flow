class ConfirmCodeArgs {
  const ConfirmCodeArgs({
    required this.email,
    this.isRegister = false,
    this.isFromLogin = false,
  });

  final String email;
  final bool isRegister;
  final bool isFromLogin;
}

class ChangePasswordArgs {
  const ChangePasswordArgs({
    required this.identifier,
  });

  final String identifier;
}
