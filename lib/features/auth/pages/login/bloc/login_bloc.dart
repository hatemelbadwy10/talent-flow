import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_event.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/app_state.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';
import '../../../../../data/error/failures.dart';
import '../repo/login_repo.dart';

class LoginBloc extends Bloc<AppEvent, AppState> {
  final LoginRepo repo;

  LoginBloc({required this.repo}) : super(Start()) {
    on<Click>((event, emit) async {
      try {
        emit(Loading());

        /// البيانات جاية من الـ arguments (من الـ UI)
        final Map<String, dynamic> data = event.arguments as Map<String, dynamic>;

        Either<ServerFailure, Response> response = await repo.logIn(data);

        response.fold(
              (fail) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: "invalid_credentials".tr(),
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent,
              ),
            );
            emit(Error());
          },
              (success) async{
                log('data$data');
                log("success${success}");
              repo.saveCredentials(data);
             repo.saveUserData(success.data);
                CustomNavigator.push(Routes.navBar, clean: true);
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
