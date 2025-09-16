import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';

class RegisterRepo extends BaseRepo {
  RegisterRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> register(data) async {
    try {
      Response response = await dioClient.post(
          uri: EndPoints.register, data: FormData.fromMap(data));

      if (response.statusCode == 200||response.statusCode == 201) {
        return Right(response);
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
