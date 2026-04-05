import 'package:equatable/equatable.dart';

class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.userType,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String userType;

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        password,
        userType,
      ];
}

class RegisterWithSocialProviderSubmitted extends RegisterEvent {
  const RegisterWithSocialProviderSubmitted({
    required this.provider,
    required this.token,
    required this.userType,
  });

  final String provider;
  final String token;
  final String userType;

  @override
  List<Object?> get props => [provider, token, userType];
}
