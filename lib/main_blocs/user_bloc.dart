import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/core/app_core.dart';
import '../app/core/app_notification.dart';
import '../app/core/styles.dart';
import '../data/config/di.dart';
import '../data/error/failures.dart';
import '../main_models/user_model.dart';
import '../main_repos/user_repo.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepo repo;

  static UserBloc get instance => sl<UserBloc>();

  UserBloc({required this.repo}) : super(const UserInitial()) {
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<UpdateCurrentUser>(_onUpdateCurrentUser);
    on<ClearCurrentUser>(_onClearCurrentUser);
  }

  bool get isLogin => repo.isLogIn;
  UserModel? user;

  Future<void> _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      final Either<ServerFailure, UserModel> response = repo.getUser();

      response.fold((fail) {
        AppCore.showSnackBar(
            notification: AppNotification(
                message: fail.error,
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent));
        user = null;
        emit(UserFailure(message: fail.error));
      }, (success) {
        user = success;
        emit(UserReady(success));
      });
    } catch (e) {
      AppCore.showSnackBar(
        notification: AppNotification(
          message: e.toString(),
          backgroundColor: Styles.IN_ACTIVE,
          borderColor: Styles.RED_COLOR,
        ),
      );
      emit(UserFailure(message: e.toString()));
    }
  }

  Future<void> _onUpdateCurrentUser(
    UpdateCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    user = event.user;
    repo.setUserData(event.user.toJson());
    emit(UserReady(event.user));
  }

  Future<void> _onClearCurrentUser(
    ClearCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    user = null;
    repo.clearUserData();
    emit(const UserInitial());
  }
}

enum UserType { company, talent }
