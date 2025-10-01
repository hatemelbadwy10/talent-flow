import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class NotificationRepo  extends BaseRepo{
  NotificationRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getNotification({String type=""}) async {
    try {
      final response = await dioClient.get(uri: "${EndPoints.notifications}$type");
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

}