import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';
import '../../../models/auth_response.dart';
import 'login_repository.dart';

class LoginRepo extends BaseRepo implements LoginRepository {
  LoginRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, AuthResponse>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.logIn,
        data: {
          'email': email,
          'password': password,
        },
      );
      return _parseAuthResponse(response);
    } catch (error) {
      return left(_failureFrom(error));
    }
  }

  @override
  Future<Either<ServerFailure, Unit>> resendVerificationEmail(
    String email,
  ) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.forgetPassword,
        data: {'identifier': email},
      );
      if (response.statusCode == 200) {
        return right(unit);
      }
      return left(ServerFailure(_messageFrom(response.data)));
    } catch (error) {
      return left(_failureFrom(error));
    }
  }

  Either<ServerFailure, AuthResponse> _parseAuthResponse(Response response) {
    if (response.statusCode != 200) {
      return left(ServerFailure(_messageFrom(response.data)));
    }
    try {
      return right(
        AuthResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        ),
      );
    } on FormatException catch (error) {
      return left(ServerFailure(error.message));
    }
  }

  ServerFailure _failureFrom(Object error) {
    if (error is DioException && error.response != null) {
      return ServerFailure(_messageFrom(error.response!.data));
    }
    return ApiErrorHandler.getServerFailure(error);
  }

  String _messageFrom(Object? data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Authentication request failed';
  }
}
