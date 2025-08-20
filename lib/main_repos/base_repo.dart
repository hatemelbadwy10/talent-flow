import 'package:shared_preferences/shared_preferences.dart';

import '../app/core/app_storage_keys.dart';
import '../data/dio/dio_client.dart';

abstract class BaseRepo {
  final SharedPreferences sharedPreferences;
  final DioClient dioClient;
  BaseRepo({required this.sharedPreferences, required this.dioClient});

  String get userId => sharedPreferences.getString(AppStorageKey.userId) ?? "";
  String get token => sharedPreferences.getString(AppStorageKey.token) ?? "";
  bool get isLogin => sharedPreferences.containsKey(AppStorageKey.isLogin);
  setMarketType(v) => sharedPreferences.setString(AppStorageKey.marketplaceType, v);
  String? get marketType => sharedPreferences.getString(AppStorageKey.marketplaceType);
}
