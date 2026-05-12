import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/data/api/end_points.dart';
import 'package:talent_flow/main_repos/base_repo.dart';
import '../app/core/app_currency.dart';
import '../app/core/app_storage_keys.dart';
import '../data/config/di.dart';
import '../data/error/api_error_handler.dart';
import '../data/error/failures.dart';
import '../main_models/user_model.dart';

class UserRepo extends BaseRepo {
  UserRepo({required super.sharedPreferences, required super.dioClient});

  bool get isLogIn => token.isNotEmpty;

  Future<Either<ServerFailure, UserModel>> fetchUserProfile() async {
    try {
      final Response response = await dioClient.get(uri: EndPoints.profile);
      final responseData = response.data;
      final payload = _asMap(responseData)?['payload'];
      final userJson = _asMap(payload)?['user'] ?? _asMap(payload) ?? _asMap(responseData)?['user'];

      if (userJson == null) {
        return Left(ServerFailure("Profile payload is empty"));
      }

      await _saveUserData(userJson, rawResponse: responseData);
      return Right(UserModel.fromJson(userJson));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Either<ServerFailure, UserModel> getUser() {
    try {
      final String? userObject =
          sharedPreferences.getString(AppStorageKey.userData);
      if (userObject != null) {
        final json = jsonDecode(userObject);
        log("userObject ==> $json");
        return Right(UserModel.fromJson(json));
      } else {
        return Left(ServerFailure("There is no data in SharedPreference"));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  setUserData(json) {
    AppCurrency.cacheFromPayload(json);
    sharedPreferences.setString(
      AppStorageKey.userId,
      json["id"]?.toString() ?? "",
    );
    sharedPreferences.setString(AppStorageKey.userData, jsonEncode(json));
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
      json["profile_image"]?.toString() ?? json["image"]?.toString() ?? "",
    );
    sharedPreferences.setBool(AppStorageKey.isLogin, true);

    if (json['user_type'] != null) {
      sl<SharedPreferences>().setBool(
        AppStorageKey.isFreelancer,
        json['user_type']?.toString() != "Entrepreneur",
      );
    }
  }

  UserModel? updateUnreadCounts({
    int? notifications,
    int? messages,
  }) {
    final rawUserData = sharedPreferences.getString(AppStorageKey.userData);
    if ((rawUserData ?? '').isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawUserData!);
      final userJson = _asMap(decoded);
      if (userJson == null) {
        return null;
      }

      if (notifications != null) {
        userJson['unread_notifications_count'] = notifications;
      }
      if (messages != null) {
        userJson['unread_messages_count'] = messages;
      }

      setUserData(userJson);
      return UserModel.fromJson(userJson);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveUserData(
    Map<String, dynamic> json, {
    dynamic rawResponse,
  }) async {
    await AppCurrency.cacheFromPayload(rawResponse ?? json);
    await sharedPreferences.setString(
      AppStorageKey.userId,
      json["id"]?.toString() ?? "",
    );
    await sharedPreferences.setString(AppStorageKey.userData, jsonEncode(json));
    await sharedPreferences.setString(
      AppStorageKey.userName,
      json["first_name"]?.toString() ?? json["name"]?.toString() ?? "",
    );
    await sharedPreferences.setString(
      AppStorageKey.userEmail,
      json["email"]?.toString() ?? "",
    );
    await sharedPreferences.setString(
      AppStorageKey.userImage,
      json["profile_image"]?.toString() ?? json["image"]?.toString() ?? "",
    );
    await sharedPreferences.setBool(AppStorageKey.isLogin, true);

    if (json['user_type'] != null) {
      await sl<SharedPreferences>().setBool(
        AppStorageKey.isFreelancer,
        json['user_type']?.toString() != "Entrepreneur",
      );
    }
  }

  clearUserData() {
    sharedPreferences.remove(AppStorageKey.userData);
    sharedPreferences.remove(AppStorageKey.userId);
    sharedPreferences.remove(AppStorageKey.userName);
    sharedPreferences.remove(AppStorageKey.userEmail);
    sharedPreferences.remove(AppStorageKey.userImage);
    sharedPreferences.remove(AppStorageKey.token);
    sharedPreferences.remove(AppStorageKey.isLogin);
    sharedPreferences.remove(AppStorageKey.isFreelancer);
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}
