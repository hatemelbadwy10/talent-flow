import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/core/app_currency.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../data/dio/dio_client.dart';
import '../models/auth_response.dart';
import '../repo/auth_device_token_sync.dart';

abstract interface class AuthSessionStore {
  Future<void> persistAuthenticatedSession(AuthResponse response);

  Future<void> saveCredentials({
    required String email,
    required String password,
  });

  Future<void> clearAuthenticatedSession();
}

final class LocalAuthSessionStore implements AuthSessionStore {
  LocalAuthSessionStore({
    required SharedPreferences sharedPreferences,
    required DioClient dioClient,
  })  : _sharedPreferences = sharedPreferences,
        _dioClient = dioClient;

  final SharedPreferences _sharedPreferences;
  final DioClient _dioClient;

  @override
  Future<void> persistAuthenticatedSession(AuthResponse response) async {
    final user = response.user;

    await AppCurrency.cacheFromPayload(response.raw);
    await _sharedPreferences.setString(
      AppStorageKey.userId,
      user['id'].toString(),
    );
    await _sharedPreferences.setString(
      AppStorageKey.userData,
      jsonEncode(user),
    );
    await _sharedPreferences.setString(
      AppStorageKey.userName,
      user['first_name']?.toString() ?? '',
    );
    await _sharedPreferences.setString(
      AppStorageKey.userEmail,
      user['email']?.toString() ?? '',
    );
    await _sharedPreferences.setString(
      AppStorageKey.userImage,
      user['image']?.toString() ?? '',
    );
    await _sharedPreferences.setBool(AppStorageKey.isLogin, true);
    await _sharedPreferences.setString(AppStorageKey.token, response.token);
    await _sharedPreferences.setBool(
      AppStorageKey.isFreelancer,
      user['user_type'] != 'Entrepreneur',
    );

    await _dioClient.updateHeader(response.token);
    await syncAuthenticatedDeviceToken(_dioClient);
  }

  @override
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) {
    return _sharedPreferences.setString(
      AppStorageKey.credentials,
      jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  @override
  Future<void> clearAuthenticatedSession() async {
    final notFirstTime =
        _sharedPreferences.getBool(AppStorageKey.notFirstTime) ?? true;
    await _sharedPreferences.clear();
    await _sharedPreferences.setBool(
      AppStorageKey.notFirstTime,
      notFirstTime,
    );
    await _dioClient.updateHeader('');
  }
}
