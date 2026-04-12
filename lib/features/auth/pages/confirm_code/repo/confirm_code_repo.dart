import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../app/core/app_currency.dart';
import '../../../../../app/core/app_storage_keys.dart';
import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';
import '../../../../auth/repo/auth_device_token_sync.dart';

class ConfirmCodeRepo extends BaseRepo {
  ConfirmCodeRepo({required super.sharedPreferences, required super.dioClient});

  Future<void> saveUserData(json) async {
    final user = json['payload']['user'];
    final token = json['payload']["token"];
    log("json: $json");
    await AppCurrency.cacheFromPayload(json);
    await sharedPreferences.setString(
      AppStorageKey.userId,
      user["id"].toString(),
    );
    await sharedPreferences.setString(AppStorageKey.userData, jsonEncode(user));
    await sharedPreferences.setBool(AppStorageKey.isLogin, true);
    await sharedPreferences.setString(
        AppStorageKey.userName, user["first_name"]);
    await sharedPreferences.setString(AppStorageKey.userEmail, user["email"]);
    await sharedPreferences.setString(AppStorageKey.userImage, user["image"]);
    await sharedPreferences.setString(AppStorageKey.token, token);
    await sharedPreferences.setBool(
      AppStorageKey.isFreelancer,
      user['user_type'] != "Entrepreneur",
    );
    await dioClient.updateHeader(token);
    await syncAuthenticatedDeviceToken(dioClient);
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

  Future<Either<ServerFailure, Response>> verifyFromRegister(
      Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(uri: EndPoints.verifyRegister, data: data);
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> verifyForgetPassword(
      Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(uri: EndPoints.verifyOtp, data: data);
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> verifyPhone(
      Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.verifyOtp,
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
