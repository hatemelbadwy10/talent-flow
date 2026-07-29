import '../../../app/core/app_storage_keys.dart';
import '../../../main_repos/base_repo.dart';
import 'splash_repository.dart';

class SplashRepo extends BaseRepo implements SplashRepository {
  SplashRepo({required super.sharedPreferences, required super.dioClient});

  // Checks if the 'notFirstTime' key exists. If it DOESN'T, it's the first time.
  @override
  bool get isFirstTime =>
      !sharedPreferences.containsKey(AppStorageKey.notFirstTime);

  // After the user sees the onboarding, we set this to true.
  @override
  Future<void> markOnboardingSeen() {
    return sharedPreferences.setBool(AppStorageKey.notFirstTime, true);
  }

  // Add this getter to check for a user token or any login flag
  @override
  bool get isLogin => sharedPreferences.containsKey(AppStorageKey.token);
}
