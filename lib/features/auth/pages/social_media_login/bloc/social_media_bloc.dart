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
import '../../../../../data/error/failures.dart';
import '../../../../../helpers/social_media_login_helper.dart';
import '../../../../../navigation/custom_navigation.dart';
import '../../../../../navigation/routes.dart';
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

      response.fold((fail) {
        AppCore.showSnackBar(
            notification: AppNotification(
                message: "invalid_credentials".tr(),
                isFloating: true,
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Colors.transparent));
        emit(Error());
      }, (success) {
        CustomNavigator.push(Routes.navBar, clean: true);
        AppCore.showSnackBar(
          notification: AppNotification(
            message: "logged_in_successfully".tr(),
            backgroundColor: Styles.ACTIVE,
            borderColor: Styles.ACTIVE,
          ),
        );
        emit(Done());
      });
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
  }
}
