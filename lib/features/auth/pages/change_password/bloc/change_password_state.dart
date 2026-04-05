import 'package:equatable/equatable.dart';

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

class ChangePasswordInProgress extends ChangePasswordState {
  const ChangePasswordInProgress();
}

class ChangePasswordFailure extends ChangePasswordState {
  const ChangePasswordFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();
}
