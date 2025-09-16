import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../app/core/app_event.dart';
import '../../../../../app/core/app_state.dart';
import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';
import '../send_verification_repo/send_verification_repo.dart';

class SendVerificationBloc extends Bloc<AppEvent, AppState> {
  final SendVerificationRepo repo;

  SendVerificationBloc({required this.repo}) : super(Start()) {
    on<Click>((event, emit) async {
      try {
        emit(Loading());
        final data = event.arguments as Map<String, dynamic>;

        Either<ServerFailure, Response> response =
        await repo.sendVerification(data);

        response.fold(
              (fail) {
                log("fail ${fail.statusCode}");
                log("fail ${fail.error}");
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error ?? "something_went_wrong".tr(), // Changed from fail.error to fail.message
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Styles.RED_COLOR,
              ),
            );
            emit(Error());
          },
              (success) {
            final String email = data["identifier"] ; // Added null safety

            AppCore.showSnackBar(
              notification: AppNotification(
                message: success.data["message"] ?? "verification_sent_successfully".tr(),
                backgroundColor: Colors.green,
                borderColor: Colors.transparent,
              ),
            );

            // Navigate to confirm code screen
            log('email: $email');
            CustomNavigator.push(
              Routes.sendCodeScreen,
              arguments: {
                "email": email,
                "isRegister": false,
              },
            );

            emit(Done());
          },
        );
      } catch (e) {
        log('Error: $e');
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