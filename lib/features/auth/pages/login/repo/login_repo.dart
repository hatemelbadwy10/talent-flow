import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../../../app/core/app_storage_keys.dart';
import '../../../../../data/api/end_points.dart';
import '../../../../../data/config/di.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';

class LoginRepo extends BaseRepo {
  LoginRepo({required super.sharedPreferences, required super.dioClient});

  saveUserData(json) async {
    final user = json['payload']['user'];
    final token = json['payload']["token"];

    await sharedPreferences.setString(AppStorageKey.userId, user["id"].toString());
    await sharedPreferences.setString(AppStorageKey.userData, jsonEncode(user));
    await sharedPreferences.setString(AppStorageKey.userName, user["first_name"]);
    await sharedPreferences.setString(AppStorageKey.userEmail, user["email"]);
    await sharedPreferences.setString(AppStorageKey.userImage, user["image"]);
    await sharedPreferences.setBool(AppStorageKey.isLogin, true);
    await sharedPreferences.setString(AppStorageKey.token, token);

    if (user['user_type'] == "Entrepreneur") {
      log("Entrepreneur");
      sl<SharedPreferences>().setBool(AppStorageKey.isFreelancer, false);
    } else {
      log("Freelancer");
      sl<SharedPreferences>().setBool(AppStorageKey.isFreelancer, true);
    }

    log("✅ User saved: ${user["first_name"]} ${user["last_name"]}");
    log("✅ Token saved: $token");
    await dioClient.updateHeader(token); // Update headers with token
  }

  saveCredentials(credentials) {
    sharedPreferences.setString(
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

  Future<Either<ServerFailure, Response>> logIn(
      Map<String, dynamic> data) async {
    try {
      Response response =
      await dioClient.post(uri: EndPoints.logIn, data: data);

      log("Login response status: ${response.statusCode}");
      log("Login response data: ${response.data}");

      if (response.statusCode == 200) {
        log("user type ${data['user_type']}");
        log("user data: $data");

        // Check if response indicates successful login
        if (response.data['status'] == true) {
          return Right(response);
        } else {
          // Status is false, but still return the response
          // The bloc will handle the verification logic
          return Right(response);
        }
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      log("Login error: $error");

      // Handle DioException specifically for better error extraction
      if (error is DioException && error.response != null) {
        final responseData = error.response!.data;
        log("DioException response data: $responseData");

        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          return left(ServerFailure(responseData['message']));
        }
      }

      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> resendVerificationEmail(
      String email) async {
    try {
      log("Sending verification email to: $email");

      final response = await dioClient.post(
        uri: EndPoints.forgetPassword, // Make sure this is the correct endpoint
        data: {"identifier": email},
      );

      log("Resend verification response: ${response.data}");

      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return left(ServerFailure(response.data['message'] ?? 'فشل في إرسال رمز التحقق'));
      }
    } catch (error) {
      log("Resend verification error: $error");
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
  Future<Either<ServerFailure, Response>> socialLogin({
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
        if (response.data['status'] == true) {
          return Right(response);
        } else {
          return Right(response); // let Bloc handle logic
        }
      } else {
        return left(ServerFailure(response.data['message'] ?? "فشل تسجيل الدخول"));
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