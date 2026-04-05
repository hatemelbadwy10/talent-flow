import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../app/core/app_storage_keys.dart';
import '../../../../../data/api/end_points.dart';
import '../../../../../data/api/response_payload_parser.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';

class ConfirmCodeRepo extends BaseRepo {
  ConfirmCodeRepo({required super.sharedPreferences, required super.dioClient});

  Future<void> saveUserData(Map<String, dynamic> json) async {
    final payload = ResponsePayloadParser.payloadMap(json);
    final user = ResponsePayloadParser.map(payload['user']);
    final token = payload["token"]?.toString() ?? '';
    log("json: $json");
    await sharedPreferences.setString(
        AppStorageKey.userId, user["id"].toString());
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

  Future<Either<ServerFailure, Map<String, dynamic>>> verifyFromRegister(
      Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(uri: EndPoints.verifyRegister, data: data);
      if (response.statusCode == 200) {
        return Right(ResponsePayloadParser.map(response.data));
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Map<String, dynamic>>> verifyForgetPassword(
      Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(uri: EndPoints.verifyOtp, data: data);
      if (response.statusCode == 200) {
        return Right(ResponsePayloadParser.map(response.data));
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
