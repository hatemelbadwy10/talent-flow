import 'package:equatable/equatable.dart';

abstract class ConfirmCodeState extends Equatable {
  const ConfirmCodeState();

  @override
  List<Object?> get props => [];
}

class ConfirmCodeInitial extends ConfirmCodeState {
  const ConfirmCodeInitial();
}

class ConfirmCodeInProgress extends ConfirmCodeState {
  const ConfirmCodeInProgress();
}

class ConfirmCodeFailure extends ConfirmCodeState {
  const ConfirmCodeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ConfirmCodeSuccess extends ConfirmCodeState {
  const ConfirmCodeSuccess();
}
