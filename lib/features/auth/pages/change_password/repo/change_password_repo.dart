import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';

class ChangePasswordRepo extends BaseRepo {
  ChangePasswordRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> changePassword(
      Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(
        uri: EndPoints.changePassword, // You need to add this endpoint
        data: data,
      );

      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }
}

