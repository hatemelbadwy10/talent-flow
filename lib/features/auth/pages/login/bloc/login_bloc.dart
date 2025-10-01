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
class SocialLoginClick extends AppEvent {
  final String provider;
  final String token;
  final String? userType;
  SocialLoginClick({required this.provider, required this.token,this.userType});
}
class LoginBloc extends Bloc<AppEvent, AppState> {
  final LoginRepo repo;

  LoginBloc({required this.repo}) : super(Start()) {
    on<Click>((event, emit) async {
      try {
        emit(Loading());

        final Map<String, dynamic> data =
        event.arguments as Map<String, dynamic>;

        Either<ServerFailure, Response> response = await repo.logIn(data);

        response.fold(
              (fail) async {
            log("fail: ${fail.error}");

            // ✅ Check for unverified account - multiple conditions
            bool isUnverifiedAccount = _isAccountUnverified(fail);

            if (isUnverifiedAccount) {
              final message = fail.error ?? 'الحساب غير مفعل';

              AppCore.showSnackBar(
                notification: AppNotification(
                  message: message,
                  isFloating: true,
                  backgroundColor: Styles.IN_ACTIVE,
                  borderColor: Colors.transparent,
                ),
              );
              log("Unverified account message: $message");

              // Send verification code
              final resendResult = await repo.resendVerificationEmail(data['email']);

              resendResult.fold(
                    (resendFail) {
                  log("Failed to resend verification email: ${resendFail.error}");
                  // Still navigate to code screen even if resend fails
                },
                    (resendSuccess) {
                  log("Verification email sent successfully");
                },
              );

              // Navigate to code verification screen
              log("data${data['email']}");
              CustomNavigator.push(
                Routes.sendCodeScreen,
                arguments: {
                  "email": data['email'],
                  "isFromLogin": true,
                },
              );

              emit(Error());
              return;
            }

            // ✅ Handle other errors (network/server/credentials)
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error ?? 'حدث خطأ ما',
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent,
              ),
            );
            emit(Error());
          },
              (success) async {
            log('Request data: $data');
            log("Response success: ${success.data}");

            final responseData = success.data;

            // ✅ Handle successful login
            await repo.saveCredentials(data);
            await repo.saveUserData(responseData);
            CustomNavigator.push(Routes.navBar, clean: true);
            emit(Done());
          },
        );
      } catch (e) {
        log("Exception in LoginBloc: $e");
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
    on<SocialLoginClick>((event, emit) async {
      try {
        emit(Loading());

        final response = await repo.socialLogin(
          provider: event.provider,
          token: event.token,
        );

        response.fold(
              (fail) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error ?? 'حدث خطأ ما',
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent,
              ),
            );
            emit(Error());
          },
              (success) async {
            final responseData = success.data;
            await repo.saveUserData(responseData);
            CustomNavigator.push(Routes.navBar, clean: true);
            emit(Done());
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
        emit(Error());
      }
    });

  }

  /// Check if the account is unverified based on multiple conditions
  bool _isAccountUnverified(ServerFailure fail) {
    // Check the specific Arabic message
    if (fail.error.contains("قم بتأكيد الحساب")) {
      return true;
    }

    // Check for English equivalent messages
    if ((fail.error.toLowerCase().contains("verify") ||
            fail.error.toLowerCase().contains("confirm") ||
            fail.error.toLowerCase().contains("unverified"))) {
      return true;
    }

    // Check if there's additional data that indicates unverified status
    // This would require modifying ServerFailure to include response data
    // For now, we'll rely on the error message

    return false;
  }
}