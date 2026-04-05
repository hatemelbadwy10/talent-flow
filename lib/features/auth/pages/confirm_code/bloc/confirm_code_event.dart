import 'package:equatable/equatable.dart';

class ConfirmCodeEvent extends Equatable {
  const ConfirmCodeEvent();

  @override
  List<Object?> get props => [];
}

class ConfirmCodeSubmitted extends ConfirmCodeEvent {
  const ConfirmCodeSubmitted({
    required this.identifier,
    required this.otp,
    this.isRegister = false,
    this.isFromLogin = false,
  });

  final String identifier;
  final String otp;
  final bool isRegister;
  final bool isFromLogin;

  @override
  List<Object?> get props => [identifier, otp, isRegister, isFromLogin];
}
