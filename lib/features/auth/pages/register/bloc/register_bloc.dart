import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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
import '../repo/register_repo.dart';

class RegisterBloc extends Bloc<AppEvent, AppState> {
  final RegisterRepo repo;

  RegisterBloc({required this.repo}) : super(Start()) {
    on<Click>((event, emit) async {
      try {
        emit(Loading());

        final data = event.arguments as Map<String, dynamic>;

        Either<ServerFailure, Response> response = await repo.register(data);

        response.fold(
              (fail) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: fail.error ?? "something_went_wrong".tr(),
                backgroundColor: Styles.IN_ACTIVE,
                borderColor: Styles.RED_COLOR,
              ),
            );
            emit(Error());
          },
              (success) {
            final String email = data["email"];

            CustomNavigator.push(
              Routes.sendCodeScreen,
              clean: true,
              arguments: {
                "email": email,
                "isRegister": true,
              },
            );
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