import 'dart:developer';
import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/repo/confirm_code_repo.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../app/core/user_completion_guard.dart';
import '../../../../../features/auth/models/auth_route_arguments.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';
import 'confirm_code_event.dart';
import 'confirm_code_state.dart';

class ConfirmCodeBloc extends Bloc<ConfirmCodeEvent, ConfirmCodeState> {
  final ConfirmCodeRepo confirmCodeRepo;

  ConfirmCodeBloc(this.confirmCodeRepo) : super(const ConfirmCodeInitial()) {
    on<ConfirmCodeSubmitted>((event, emit) async {
      try {
        emit(const ConfirmCodeInProgress());
        final data = {
          "identifier": event.identifier,
          "otp": event.otp,
          "isRegister": event.isRegister,
          "isFromLogin": event.isFromLogin,
        };
        dev.log('data $data');
        log("data${event.isRegister}");
        log("data${event.isFromLogin}");

        log("isRegister ${event.isRegister} - isFromLogin ${event.isFromLogin}");
        final response = event.isRegister || event.isFromLogin
            ? await confirmCodeRepo.verifyFromRegister(data)
            : await confirmCodeRepo.verifyForgetPassword(data);

        await response.fold<Future<void>>(
          (fail) async {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error,
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent,
              ),
            );
            if (emit.isDone) return;
            emit(ConfirmCodeFailure(fail.error));
          },
          (success) async {
            log(
              'isRegister ${event.isRegister} - isFromLogin ${event.isFromLogin}',
            );

            if (event.isRegister) {
              /// من الريجستر → يروح للهوم
              await confirmCodeRepo.saveUserData(success);
              await confirmCodeRepo.saveCredentials(data);
              await UserCompletionGuard.handlePostAuthNavigation();
            } else if (event.isFromLogin) {
              /// من اللوجين → يرجع للوجين
              AppCore.showSnackBar(
                notification: AppNotification(
                  message: "تم تفعيل الحساب بنجاح. سجل الدخول الآن".tr(),
                  backgroundColor: Styles.ACTIVE,
                  borderColor: Colors.transparent,
                ),
              );
              CustomNavigator.push(Routes.login, clean: true);
            } else {
              /// من forget password → يروح يغير الباسورد
              CustomNavigator.push(
                Routes.forgetPassword,
                arguments: ChangePasswordArgs(identifier: event.identifier),
              );
            }

            if (emit.isDone) return;
            emit(const ConfirmCodeSuccess());
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
        emit(ConfirmCodeFailure(e.toString()));
      }
    });
  }
}
