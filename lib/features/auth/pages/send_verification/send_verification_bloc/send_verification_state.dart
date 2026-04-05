import 'package:equatable/equatable.dart';

abstract class SendVerificationState extends Equatable {
  const SendVerificationState();

  @override
  List<Object?> get props => [];
}

class SendVerificationInitial extends SendVerificationState {
  const SendVerificationInitial();
}

class SendVerificationInProgress extends SendVerificationState {
  const SendVerificationInProgress();
}

class SendVerificationFailure extends SendVerificationState {
  const SendVerificationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class SendVerificationSuccess extends SendVerificationState {
  const SendVerificationSuccess();
}
