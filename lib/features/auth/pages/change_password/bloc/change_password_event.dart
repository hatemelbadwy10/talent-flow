import 'package:equatable/equatable.dart';

class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  const ChangePasswordSubmitted({
    required this.identifier,
    required this.password,
    required this.passwordConfirmation,
  });

  final String identifier;
  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [identifier, password, passwordConfirmation];
}
