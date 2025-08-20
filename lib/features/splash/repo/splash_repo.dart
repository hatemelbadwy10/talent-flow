import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../data/api/end_points.dart';
import '../../../main_repos/base_repo.dart';

class SplashRepo extends BaseRepo {
  SplashRepo({required super.sharedPreferences, required super.dioClient});

  // Checks if the 'notFirstTime' key exists. If it DOESN'T, it's the first time.
  bool get isFirstTime => !sharedPreferences.containsKey(AppStorageKey.notFirstTime);

  // After the user sees the onboarding, we set this to true.
   void setFirstTime() {
     sharedPreferences.setBool(AppStorageKey.notFirstTime, true);
   }

  // Add this getter to check for a user token or any login flag
  @override
  bool get isLogin => sharedPreferences.containsKey(AppStorageKey.token);
}