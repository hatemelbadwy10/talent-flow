import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/api/response_payload_parser.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';

class RegisterRepo extends BaseRepo {
  RegisterRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Unit>> register(
      Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(
          uri: EndPoints.register, data: FormData.fromMap(data));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(unit);
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, String>> socialLogin({
    required String provider,
    required String token,
  }) async {
    try {
      final data = {
        "provider": provider,
        "token": token,
      };

      log("🔹 Social login request: $data");

      Response response =
          await dioClient.post(uri: EndPoints.socialLogin, data: data);

      log("Social login response status: ${response.statusCode}");
      log("Social login response data: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = ResponsePayloadParser.map(response.data);
        final payload = responseData['payload'];
        if (payload is Map && payload['email'] != null) {
          return Right(payload['email'].toString());
        }
        if (responseData['email'] != null) {
          return Right(responseData['email'].toString());
        }
        return left(ServerFailure('Email is missing from response.'));
      } else {
        return left(
            ServerFailure(response.data['message'] ?? "فشل تسجيل الدخول"));
      }
    } catch (error) {
      log("Social login error: $error");

      if (error is DioException && error.response != null) {
        final responseData = error.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          return left(ServerFailure(responseData['message']));
        }
      }

      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
