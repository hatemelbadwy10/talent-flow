import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../features/auth/models/auth_route_arguments.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';
import '../repo/register_repo.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepo repo;

  RegisterBloc({required this.repo}) : super(const RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      try {
        emit(const RegisterInProgress());
        final data = {
          "first_name": event.firstName,
          "last_name": event.lastName,
          "email": event.email,
          "password": event.password,
          "user_type": event.userType,
        };
        final response = await repo.register(data);

        response.fold(
          (fail) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Styles.RED_COLOR,
              ),
            );
            emit(RegisterFailure(fail.error));
          },
          (_) {
            CustomNavigator.push(
              Routes.sendCodeScreen,
              arguments: ConfirmCodeArgs(
                email: event.email,
                isRegister: true,
              ),
            );
            emit(const RegisterSuccess());
          },
        );
      } catch (e) {
        AppCore.showSnackBar(
          notification: AppNotification(
            message: e.toString(),
            backgroundColor: Styles.IN_ACTIVE,
            borderColor: Styles.RED_COLOR,
          ),
        );
        emit(RegisterFailure(e.toString()));
      }
    });
    on<RegisterWithSocialProviderSubmitted>((event, emit) async {
      try {
        emit(const RegisterInProgress());

        final response = await repo.socialLogin(
          provider: event.provider,
          token: event.token,
        );

        response.fold(
          (fail) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error,
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent,
              ),
            );
            emit(RegisterFailure(fail.error));
          },
          (email) async {
            CustomNavigator.push(
              Routes.sendCodeScreen,
              arguments: ConfirmCodeArgs(email: email),
            );
            emit(const RegisterSuccess());
          },
        );
      } catch (e) {
        log("Exception in SocialLoginClick: $e");
        AppCore.showSnackBar(
          notification: AppNotification(
            message: e.toString(),
            backgroundColor: Styles.IN_ACTIVE,
            borderColor: Styles.RED_COLOR,
          ),
        );
        emit(RegisterFailure(e.toString()));
      }
    });
  }
}
