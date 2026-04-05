import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../features/auth/models/auth_route_arguments.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';
import '../send_verification_repo/send_verification_repo.dart';
import 'send_verification_event.dart';
import 'send_verification_state.dart';

class SendVerificationBloc
    extends Bloc<SendVerificationEvent, SendVerificationState> {
  final SendVerificationRepo repo;

  SendVerificationBloc({required this.repo})
      : super(const SendVerificationInitial()) {
    on<VerificationRequestSubmitted>((event, emit) async {
      try {
        emit(const SendVerificationInProgress());
        final data = {"identifier": event.identifier};
        final response = await repo.sendVerification(data);

        response.fold(
          (fail) {
            log("fail ${fail.statusCode}");
            log("fail ${fail.error}");
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error.isNotEmpty
                    ? fail.error
                    : "something_went_wrong".tr(),
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Styles.RED_COLOR,
              ),
            );
            emit(SendVerificationFailure(fail.error));
          },
          (message) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: message.isNotEmpty
                    ? message
                    : "verification_sent_successfully".tr(),
                backgroundColor: Colors.green,
                borderColor: Colors.transparent,
              ),
            );

            log('email: ${event.identifier}');
            CustomNavigator.push(
              Routes.sendCodeScreen,
              arguments: ConfirmCodeArgs(
                email: event.identifier,
              ),
            );

            emit(const SendVerificationSuccess());
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
        emit(SendVerificationFailure(e.toString()));
      }
    });
  }
}
