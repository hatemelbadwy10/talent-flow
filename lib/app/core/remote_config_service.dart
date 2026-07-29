import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static const String showSocialAuthKey = 'showSocialAuth';
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static bool get showSocialAuth => _remoteConfig.getBool(showSocialAuthKey);

  static Future<void> initialize() async {
    try {
      log('Remote Config initialization started');
      await _remoteConfig.setDefaults(const {
        showSocialAuthKey: false,
      });
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(minutes: 5),
        ),
      );
      final bool activated = await _remoteConfig.fetchAndActivate();
      final bool showSocialAuth = _remoteConfig.getBool(showSocialAuthKey);
      final ValueSource source =
          _remoteConfig.getValue(showSocialAuthKey).source;

      log(
        'Remote Config initialized: '
        'activated=$activated, '
        '$showSocialAuthKey=$showSocialAuth, '
        'source=$source, '
        'lastFetchStatus=${_remoteConfig.lastFetchStatus}, '
        'lastFetchTime=${_remoteConfig.lastFetchTime}',
      );
    } catch (error, stackTrace) {
      log(
        'Remote Config initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
