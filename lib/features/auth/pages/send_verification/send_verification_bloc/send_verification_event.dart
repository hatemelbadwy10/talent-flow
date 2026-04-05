import 'package:equatable/equatable.dart';

class SendVerificationEvent extends Equatable {
  const SendVerificationEvent();

  @override
  List<Object?> get props => [];
}

class VerificationRequestSubmitted extends SendVerificationEvent {
  const VerificationRequestSubmitted({
    required this.identifier,
  });

  final String identifier;

  @override
  List<Object?> get props => [identifier];
}
