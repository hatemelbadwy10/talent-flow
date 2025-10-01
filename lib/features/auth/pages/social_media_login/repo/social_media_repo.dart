import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/navigation/routes.dart';

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
  }

  saveUserToken(token) {
    sharedPreferences.setString(AppStorageKey.token, token);
    dioClient.updateHeader(token);
  }

  Future<Either<ServerFailure, Response>> signInWithSocialMedia(
      SocialMediaProvider provider) async {
    print("provider: $provider");
    left(ApiErrorHandler.getServerFailure("xx"));
    try {
      Either<ServerFailure, SocialMediaModel>? socialResponse;
      if (provider == SocialMediaProvider.google) {
        socialResponse = await socialMediaLoginHelper.googleLogin();
      }

      if (provider == SocialMediaProvider.facebook) {
        socialResponse = await socialMediaLoginHelper.facebookLogin();
      }

      if (provider == SocialMediaProvider.apple) {
        socialResponse = await socialMediaLoginHelper.appleLogin();
      }

      return socialResponse!.fold((fail) {
        print("/////////////////////////////////");
        print("fail: $fail");
        print("/////////////////////////////////");
        return left(fail);
      }, (success) async {
        print("/////////////////////////////////");
        print("success: ${success.idToken}");
        print("success: ${success.image}");
        print("success: ${success.provider}");
        print("success: ${success.uid}");

        print("/////////////////////////////////");
        log("success: $success");

        Response response =
            await dioClient.post(uri: EndPoints.socialMediaAuth, data: {
          "token": success.idToken,
          "provider": provider.name,
          "user_type":
              sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                      true
                  ? "Freelancer"
                  : "Entrepreneur",
        });
        print("response: ${response.data}");

        if (response.statusCode == 200) {
          print("response: ${response.data}");
          saveUserData(response.data["data"]);
          saveUserToken(response.data['data']["token"]);
          return Right(response);
        } else {
          print("error: ${response.data['message']}");
          return left(
              ApiErrorHandler.getServerFailure(response.data['message']));
        }
      });
    } catch (error) {
      print("error: ${error.toString()}");
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
