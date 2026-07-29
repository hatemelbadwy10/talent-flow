abstract interface class SplashRepository {
  bool get isFirstTime;

  bool get isLogin;

  Future<void> markOnboardingSeen();
}
