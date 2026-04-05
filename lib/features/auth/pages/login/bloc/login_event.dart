import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LoginWithSocialProviderSubmitted extends LoginEvent {
  const LoginWithSocialProviderSubmitted({
    required this.provider,
    required this.token,
  });

  final String provider;
  final String token;

  @override
  List<Object?> get props => [provider, token];
}
