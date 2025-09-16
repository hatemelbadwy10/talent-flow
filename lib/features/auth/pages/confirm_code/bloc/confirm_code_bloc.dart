import 'dart:developer';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/repo/confirm_code_repo.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_event.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/app_state.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';

class ConfirmCodeBloc extends Bloc<AppEvent, AppState> {
  final ConfirmCodeRepo confirmCodeRepo;

  ConfirmCodeBloc(this.confirmCodeRepo) : super(Start()) {
    on<Click>((event, emit) async {
      try {
        emit(Loading());

        /// البيانات جاية من الـ arguments (من الـ UI)
        final Map<String, dynamic> data = event.arguments as Map<String, dynamic>;
        dev.log('data $data');
        final bool isRegister = data['isRegister'] ?? false;
        final String email = data['identifier'] ?? '';


        Either<ServerFailure, Response> response;

        // Choose the appropriate verification method based on isRegister flag
        if (isRegister) {
          // For registration verification
          response = await confirmCodeRepo.verifyFromRegister(data);
        } else {
          // For forget password verification
          response = await confirmCodeRepo.verifyForgetPassword(data);
        }

        response.fold(
              (fail) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error ?? "invalid_credentials".tr(),
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent,
              ),
            );
            emit(Error());
          },
              (success) {
                log('isRegister $isRegister');
            if (isRegister) {
              confirmCodeRepo.saveUserData(success.data);
              confirmCodeRepo.saveCredentials(data);
              CustomNavigator.push(Routes.navBar, clean: true);
            } else {
              CustomNavigator.push(
                Routes.forgetPassword,
                arguments: {
                  "identifier": email,
                },
              );
            }
            emit(Done());
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
        emit(Error());
      }
    });
  }
}