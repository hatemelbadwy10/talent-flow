import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/auth/pages/change_password/repo/change_password_repo.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ChangePasswordRepo repo;

  ChangePasswordBloc({required this.repo})
      : super(const ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>((event, emit) async {
      try {
        emit(const ChangePasswordInProgress());
        final data = {
          "identifier": event.identifier,
          "password": event.password,
          "password_confirmation": event.passwordConfirmation,
        };

        final response = await repo.changePassword(data);

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
            emit(ChangePasswordFailure(fail.error));
          },
          (_) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: "change_password.success".tr(),
                isFloating: true,
                backgroundColor: Colors.green,
                borderColor: Colors.transparent,
              ),
            );
            CustomNavigator.push(Routes.login, clean: true);
            emit(const ChangePasswordSuccess());
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
        emit(ChangePasswordFailure(e.toString()));
      }
    });
  }
}
