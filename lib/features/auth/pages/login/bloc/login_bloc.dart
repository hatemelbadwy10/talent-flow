import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../app/core/user_completion_guard.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../features/auth/models/auth_route_arguments.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';
import '../repo/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo repo;

  LoginBloc({required this.repo}) : super(const LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      try {
        emit(const LoginInProgress());
        final data = {
          "email": event.email,
          "password": event.password,
        };

        Either<ServerFailure, Map<String, dynamic>> response =
            await repo.logIn(data);

        await response.fold<Future<void>>(
          (fail) async {
            log("fail: ${fail.error}");

            // ✅ Check for unverified account - multiple conditions
            bool isUnverifiedAccount = _isAccountUnverified(fail);

            if (isUnverifiedAccount) {
              final message = fail.error;

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
              final resendResult =
                  await repo.resendVerificationEmail(event.email);

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
                arguments: ConfirmCodeArgs(
                  email: event.email,
                  isFromLogin: true,
                ),
              );

              if (emit.isDone) return;
              emit(LoginFailure(message));
              return;
            }

            // ✅ Handle other errors (network/server/credentials)
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error,
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent,
              ),
            );
            if (emit.isDone) return;
            emit(LoginFailure(fail.error));
          },
          (success) async {
            log('Request data: $data');
            log("Response success: $success");

            // ✅ Handle successful login
            await repo.saveCredentials(data);
            await repo.saveUserData(success);
            await UserCompletionGuard.handlePostAuthNavigation();
            if (emit.isDone) return;
            emit(const LoginSuccess());
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
        emit(LoginFailure(e.toString()));
      }
    });
    on<LoginWithSocialProviderSubmitted>((event, emit) async {
      try {
        emit(const LoginInProgress());

        final response = await repo.socialLogin(
          provider: event.provider,
          token: event.token,
        );

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
            emit(LoginFailure(fail.error));
          },
          (success) async {
            await repo.saveUserData(success);
            await UserCompletionGuard.handlePostAuthNavigation();
            if (emit.isDone) return;
            emit(const LoginSuccess());
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
        emit(LoginFailure(e.toString()));
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
