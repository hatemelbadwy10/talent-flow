import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../../../app/core/app_storage_keys.dart';
import '../../../../../data/api/end_points.dart';
import '../../../../../data/api/response_payload_parser.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';

class LoginRepo extends BaseRepo {
  LoginRepo({required super.sharedPreferences, required super.dioClient});

  Future<void> saveUserData(Map<String, dynamic> json) async {
    final payload = ResponsePayloadParser.payloadMap(json);
    final user = ResponsePayloadParser.map(payload['user']);
    final token = payload["token"]?.toString() ?? '';

    await sharedPreferences.setString(
        AppStorageKey.userId, user["id"].toString());
    await sharedPreferences.setString(AppStorageKey.userData, jsonEncode(user));
    await sharedPreferences.setString(
        AppStorageKey.userName, user["first_name"]);
    await sharedPreferences.setString(AppStorageKey.userEmail, user["email"]);
    await sharedPreferences.setString(AppStorageKey.userImage, user["image"]);
    await sharedPreferences.setBool(AppStorageKey.isLogin, true);
    await sharedPreferences.setString(AppStorageKey.token, token);

    if (user['user_type'] == "Entrepreneur") {
      log("Entrepreneur");
      await sharedPreferences.setBool(AppStorageKey.isFreelancer, false);
    } else {
      log("Freelancer");
      await sharedPreferences.setBool(AppStorageKey.isFreelancer, true);
    }

    log("✅ User saved: ${user["first_name"]} ${user["last_name"]}");
    log("✅ Token saved: $token");
    await dioClient.updateHeader(token); // Update headers with token
  }

  Future<void> saveCredentials(Map<String, dynamic> credentials) async {
    await sharedPreferences.setString(
        AppStorageKey.credentials, jsonEncode(credentials));
  }

  getCredentials() {
    if (sharedPreferences.containsKey(AppStorageKey.credentials)) {
      return jsonDecode(sharedPreferences.getString(
            AppStorageKey.credentials,
          ) ??
          "{}");
    }
  }

  Future<Either<ServerFailure, Map<String, dynamic>>> logIn(
      Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(uri: EndPoints.logIn, data: data);

      log("Login response status: ${response.statusCode}");
      log("Login response data: ${response.data}");

      if (response.statusCode == 200) {
        log("user type ${data['user_type']}");
        log("user data: $data");
        return Right(ResponsePayloadParser.map(response.data));
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      log("Login error: $error");

      // Handle DioException specifically for better error extraction
      if (error is DioException && error.response != null) {
        final responseData = error.response!.data;
        log("DioException response data: $responseData");

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          return left(ServerFailure(responseData['message']));
        }
      }

      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, String>> resendVerificationEmail(
      String email) async {
    try {
      log("Sending verification email to: $email");

      final response = await dioClient.post(
        uri: EndPoints.forgetPassword, // Make sure this is the correct endpoint
        data: {"identifier": email},
      );

      log("Resend verification response: ${response.data}");

      if (response.statusCode == 200) {
        return Right(
          ResponsePayloadParser.map(response.data)['message']?.toString() ?? '',
        );
      } else {
        return left(ServerFailure(
            response.data['message'] ?? 'فشل في إرسال رمز التحقق'));
      }
    } catch (error) {
      log("Resend verification error: $error");
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Map<String, dynamic>>> socialLogin({
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
        return Right(ResponsePayloadParser.map(response.data));
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
