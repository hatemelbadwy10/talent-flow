import 'package:equatable/equatable.dart';

import '../main_models/user_model.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserReady extends UserState {
  const UserReady(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class UserFailure extends UserState {
  const UserFailure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}
