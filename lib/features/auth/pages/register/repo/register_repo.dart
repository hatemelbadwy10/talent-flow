import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';
import '../model/register_request.dart';
import 'register_repository.dart';

class RegisterRepo extends BaseRepo implements RegisterRepository {
  RegisterRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, Unit>> register(
    RegisterRequest request,
  ) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.register,
        data: FormData.fromMap(request.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return right(unit);
      }
      return left(ServerFailure(_messageFrom(response.data)));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String _messageFrom(Object? data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Registration request failed';
  }
}
