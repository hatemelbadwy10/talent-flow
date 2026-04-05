import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../app/core/app_storage_keys.dart';
import '../../../../../data/api/end_points.dart';
import '../../../../../data/config/di.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../helpers/social_media_login_helper.dart';
import '../../../../../main_repos/base_repo.dart';

class SocialMediaRepo extends BaseRepo {
  SocialMediaRepo(
      {required this.socialMediaLoginHelper,
      required super.sharedPreferences,
      required super.dioClient});

  final SocialMediaLoginHelper socialMediaLoginHelper;

  saveUserData(json) {
    sharedPreferences.setString(AppStorageKey.userId, json["id"].toString());
    sharedPreferences.setString(AppStorageKey.userData, jsonEncode(json));
    sharedPreferences.setBool(AppStorageKey.isLogin, true);
    sharedPreferences.setString(
      AppStorageKey.userName,
      json["first_name"]?.toString() ?? json["name"]?.toString() ?? "",
    );
    sharedPreferences.setString(
      AppStorageKey.userEmail,
      json["email"]?.toString() ?? "",
    );
    sharedPreferences.setString(
      AppStorageKey.userImage,
      json["image"]?.toString() ?? "",
    );
    // ✅ Save user type correctly
    bool isFreelancer = json["user_type"]?.toString() == "Freelancer";
    sharedPreferences.setBool(AppStorageKey.isFreelancer, isFreelancer);
    log("User saved: ${json["first_name"]} (Type: ${json["user_type"]}, isFreelancer: $isFreelancer)");
  }

  saveUserToken(token) {
    sharedPreferences.setString(AppStorageKey.token, token);
    dioClient.updateHeader(token);
  }

  Future<Either<ServerFailure, Response>> signInWithSocialMedia(
      SocialMediaProvider provider) async {
    log("provider: $provider");
    try {
      Either<ServerFailure, SocialMediaModel>? socialResponse;
      if (provider == SocialMediaProvider.google) {
        socialResponse = await socialMediaLoginHelper.googleLogin();
      }

      // if (provider == SocialMediaProvider.facebook) {
      //   socialResponse = await socialMediaLoginHelper.facebookLogin();
      // }

      if (provider == SocialMediaProvider.apple) {
        socialResponse = await socialMediaLoginHelper.appleLogin();
      }

      if (socialResponse == null) {
        return left(ServerFailure("Unsupported social provider"));
      }

      return await socialResponse.fold<Future<Either<ServerFailure, Response>>>(
        (fail) async {
          log("social login fail: ${fail.error}");
          return left(fail);
        },
        (success) async {
          log("success: $success");

          // ✅ Validate the model before sending to backend
          if (success.idToken == null || success.idToken!.isEmpty) {
            log("error: Firebase ID token is null or empty");
            return left(ServerFailure("Authentication failed: No valid token"));
          }

          try {
            final payload = {
              "token": success.idToken,
              "provider": provider.name,
              "user_type":
                  sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                          true
                      ? "Freelancer"
                      : "Entrepreneur",
            };

            log("Sending payload to backend: $payload");

            final response = await dioClient.post(
                uri: EndPoints.socialMediaAuth, data: payload);
            log("response: ${response.data}");

            if (response.statusCode == 200) {
              // ✅ Backend returns data in 'payload' key, not 'data'
              final userData = response.data["payload"]["user"];
              final token = response.data["payload"]["token"];

              saveUserData(userData);
              saveUserToken(token);
              return Right(response);
            }

            log("error: ${response.data['message']}");
            return left(
              ServerFailure(
                response.data['message']?.toString() ?? "Social login failed",
                statusCode: response.statusCode,
              ),
            );
          } catch (error) {
            log("social auth request error: $error");

            if (error is DioException && error.response != null) {
              final responseData = error.response!.data;
              final message = responseData is Map<String, dynamic>
                  ? responseData['message']?.toString()
                  : null;

              return left(
                ServerFailure(
                  message ?? ApiErrorHandler.getServerFailure(error).error,
                  statusCode: error.response!.statusCode,
                ),
              );
            }

            return left(ApiErrorHandler.getServerFailure(error));
          }
        },
      );
    } catch (error) {
      log("error: ${error.toString()}");
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
