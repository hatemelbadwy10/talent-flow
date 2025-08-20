import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecureStorage {
  final FlutterSecureStorage flutterSecureStorage;

  SecureStorage({required this.flutterSecureStorage});

  AndroidOptions _getAndroidOptions() => AndroidOptions(
        encryptedSharedPreferences: true,
        sharedPreferencesName: dotenv.env["SHARED_PREFERENCES_NAME"],
      );
  IOSOptions _getIosOptions() => const IOSOptions();

  Future<String?> getString(key) async {
    return await flutterSecureStorage.read(
        key: key, aOptions: _getAndroidOptions(), iOptions: _getIosOptions());
  }

  Future<bool> getBool(key) async {
    return await flutterSecureStorage.read(
            key: key,
            aOptions: _getAndroidOptions(),
            iOptions: _getIosOptions()) ==
        "true";
  }

  Future<void> write({required String key, required String value}) async {
    return await flutterSecureStorage.write(
        key: key,
        value: value,
        aOptions: _getAndroidOptions(),
        iOptions: _getIosOptions());
  }
}
