import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../app/core/app_storage_keys.dart';
import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';

class ConfirmCodeRepo extends BaseRepo {
  ConfirmCodeRepo({required super.sharedPreferences, required super.dioClient});

  saveUserData(json) {
    sharedPreferences.setString(AppStorageKey.userId, json["id"].toString());
    sharedPreferences.setString(AppStorageKey.userData, jsonEncode(json));
    sharedPreferences.setBool(AppStorageKey.isLogin, true);
    sharedPreferences.setString(AppStorageKey.token, json["token"]);
    dioClient.updateHeader(json["token"]);
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
}
