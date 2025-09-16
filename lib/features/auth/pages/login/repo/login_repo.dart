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

class LoginRepo extends BaseRepo{
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
    if(user['user_type']=="Entrepreneur"){
      log("Entrepreneur");
      sl<SharedPreferences>().setBool(AppStorageKey.isFreelancer,false);
    }
    else{
      log("Freelancer");
      sl<SharedPreferences>().setBool(AppStorageKey.isFreelancer,true);
    }
    log("✅ User saved: ${user["first_name"]} ${user["last_name"]}");
    log("✅ Token saved: $token");

 await   dioClient.updateHeader(token); // Update headers with token
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
      if (response.statusCode == 200) {
        log("user type ${data['user_type']}");
        log("user type ${data}");

        // if (response.data['data']["email_verified_at"] != null) {
        //   saveUserToken(response.data["data"]["token"]);
        //   saveUserData(response.data["data"]["user"]);
        // }
        return Right(response);
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

}