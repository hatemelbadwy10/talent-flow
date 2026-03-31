import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_event.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/app_state.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../app/core/user_completion_guard.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../helpers/social_media_login_helper.dart';
import '../repo/social_media_repo.dart';

class SocialMediaBloc extends Bloc<AppEvent, AppState> {
  final SocialMediaRepo repo;
  SocialMediaBloc({required this.repo}) : super(Start()) {
    on<Click>(onClick);
  }

  Future<void> onClick(Click event, Emitter<AppState> emit) async {
    try {
      emit(Loading());

      Either<ServerFailure, Response> response = await repo
          .signInWithSocialMedia(event.arguments as SocialMediaProvider);

      await response.fold<Future<void>>((fail) async {
        log("Social login failed: ${fail.error} (Code: ${fail.statusCode})");
        
        // ✅ Show the actual error, not generic message
        String errorMessage = fail.error.isNotEmpty
            ? fail.error
            : "invalid_credentials".tr();
        
        AppCore.showSnackBar(
            notification: AppNotification(
                message: errorMessage,
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent));
        if (emit.isDone) return;
        emit(Error());
      }, (success) async {
        await UserCompletionGuard.handlePostAuthNavigation();
        AppCore.showSnackBar(
          notification: AppNotification(
            message: "logged_in_successfully".tr(),
            backgroundColor: Styles.ACTIVE,
            borderColor: Styles.ACTIVE,
          ),
        );
        if (emit.isDone) return;
        emit(Done());
      });
    } catch (e) {
      log('Social media auth exception: $e');
      AppCore.showSnackBar(
        notification: AppNotification(
          message: e.toString(),
          backgroundColor: Styles.IN_ACTIVE,
          borderColor: Styles.RED_COLOR,
        ),
      );
      emit(Error());
    }
  }
}
