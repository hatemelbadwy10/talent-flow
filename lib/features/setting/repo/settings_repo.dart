import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/model/help_model.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';

class SettingsRepo extends BaseRepo {
  SettingsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> help(HelpModel model) async {
    try {
      final response = await dioClient.post(
          uri: EndPoints.help, queryParameters: model.toJson());
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> logout() async {
    try {
      final response = await dioClient.post(uri: EndPoints.logout);
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
