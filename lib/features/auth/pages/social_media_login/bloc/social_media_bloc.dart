import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../app/core/user_completion_guard.dart';
import '../repo/social_media_repo.dart';
import 'social_media_event.dart';
import 'social_media_state.dart';

class SocialMediaBloc extends Bloc<SocialMediaEvent, SocialMediaState> {
  final SocialMediaRepo repo;
  SocialMediaBloc({required this.repo}) : super(const SocialMediaInitial()) {
    on<SocialProviderAuthenticationRequested>(onClick);
  }

  Future<void> onClick(
    SocialProviderAuthenticationRequested event,
    Emitter<SocialMediaState> emit,
  ) async {
    try {
      emit(const SocialMediaInProgress());

      final response = await repo.signInWithSocialMedia(event.provider);

      await response.fold<Future<void>>((fail) async {
        log("Social login failed: ${fail.error} (Code: ${fail.statusCode})");

        // ✅ Show the actual error, not generic message
        String errorMessage =
            fail.error.isNotEmpty ? fail.error : "invalid_credentials".tr();

        AppCore.showSnackBar(
            notification: AppNotification(
                message: errorMessage,
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent));
        if (emit.isDone) return;
        emit(SocialMediaFailure(errorMessage));
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
        emit(const SocialMediaSuccess());
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
      emit(SocialMediaFailure(e.toString()));
    }
  }
}
