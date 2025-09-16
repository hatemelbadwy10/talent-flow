import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../app/core/app_storage_keys.dart';
import '../api/end_points.dart';
import 'api_client.dart';
import 'logging_interceptor.dart';

class DioClient extends ApiClient {
  final String baseUrl;
  final LoggingInterceptor loggingInterceptor;
  final SharedPreferences sharedPreferences;
  final Dio dio;

  DioClient(
      this.baseUrl, {
        required this.dio,
        required this.loggingInterceptor,
        required this.sharedPreferences,
      }) {
    dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 60)
      ..options.receiveTimeout = const Duration(seconds: 60);

    dio.interceptors.add(PrettyDioLogger(
      request: true,
      responseBody: true,
      requestBody: true,
      requestHeader: true,
      enabled: kDebugMode,
    ));
  }

  /// تحديث الهيدر بناءً على اللغة الحالية والـ token
  void _updateHeaders({String? token}) {
    final lang =
        CustomNavigator.navigatorState.currentContext?.locale.languageCode ??
            "ar";

    dio.options.headers = {
      "Accept": "application/json",
      "x-api-key": EndPoints.apiKey,
      "Accept-Language": lang,
      if (token != null)
        "Authorization": "Bearer $token"
      else if (sharedPreferences.getString(AppStorageKey.token) != null)
        "Authorization":
        "Bearer ${sharedPreferences.getString(AppStorageKey.token)}",
    };
  }

  /// تحديث الهيدر بالـ token الجديد (مثلاً بعد تسجيل الدخول)
  Future<void> updateHeader(String? token) async {
    _updateHeaders(token: token);
  }

  /// تحديث الهيدر بالـ token المخزن حاليًا
  Future<void> refreshHeader() async {
    _updateHeaders();
  }

  /// تحديث اللغة في الهيدر (لو عايز تفرض لغة جديدة غير اللي في context)
  void updateLang(String lang) {
    dio.options.headers = {
      "Accept": "application/json",
      "x-api-key": EndPoints.apiKey,
      "Accept-Language": lang,
      if (sharedPreferences.getString(AppStorageKey.token) != null)
        "Authorization": "Bearer ${sharedPreferences.getString(AppStorageKey.token)}",
    };
  }

  @override
  Future<Response> get({
    required String uri,
    bool useGoogleUri = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      _updateHeaders();

      dio.options.baseUrl =
      useGoogleUri ? EndPoints.googleMapsBaseUrl : baseUrl;

      final response = await dio.get(uri, queryParameters: queryParameters);
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> post({
    required String uri,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onReceiveProgress,
    dynamic data,
  }) async {
    try {
      _updateHeaders();
      dio.options.baseUrl = baseUrl;

      final response = await dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> put({
    required String uri,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      _updateHeaders();
      dio.options.baseUrl = baseUrl;

      final response = await dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on FormatException {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> patch({
    required String uri,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      _updateHeaders();
      dio.options.baseUrl = baseUrl;

      final response = await dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on FormatException {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> delete({
    required String uri,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      _updateHeaders();
      dio.options.baseUrl = baseUrl;

      final response = await dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on FormatException {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }
}
