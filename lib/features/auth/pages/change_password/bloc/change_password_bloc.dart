import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/features/auth/pages/change_password/repo/change_password_repo.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';

class ChangePasswordBloc extends Bloc<AppEvent, AppState> {
  final ChangePasswordRepo repo;

  ChangePasswordBloc({required this.repo}) : super(Start()) {
    on<Click>((event, emit) async {
      try {
        emit(Loading());

        final Map<String, dynamic> data = event.arguments as Map<String, dynamic>;

        Either<ServerFailure, Response> response = await repo.changePassword(data);

        response.fold(
              (fail) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error ?? "change_password.error_failed".tr(),
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent,
              ),
            );
            emit(Error());
          },
              (success) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: "change_password.success".tr(),
                isFloating: true,
                backgroundColor: Colors.green,
                borderColor: Colors.transparent,
              ),
            );
            CustomNavigator.push(Routes.login, clean: true);
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