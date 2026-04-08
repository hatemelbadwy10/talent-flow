// ignore_for_file: prefer_conditional_assignment

part of 'notification_helper.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestorm,
  // make sure you call initializeApp before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('on Message background notification ${message.data}');
  log('on Message background data ${message.notification?.body}');
  log('Handling a background message: ${message.notification?.toMap()}');
  handlePath(message.data);
}

FirebaseMessaging? _firebaseMessaging;

class FirebaseNotifications {
  static FirebaseNotifications? _instance;
  static bool _isInitialized = false;

  FirebaseNotifications._internal();

  factory FirebaseNotifications() {
    _instance ??= FirebaseNotifications._internal();
    return _instance!;
  }

  static Future<void> setUpFirebase() async {
    if (_isInitialized) {
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _firebaseMessaging = FirebaseMessaging.instance;
    await _firebaseMessaging!.setAutoInitEnabled(true);
    final notificationSettings = await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    log(
      'FCM authorization status: ${notificationSettings.authorizationStatus.name}',
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await localNotification();
    await _cacheFcmToken(await _firebaseMessaging!.getToken());
    _firebaseMessaging!.onTokenRefresh.listen(_cacheFcmToken);
    await firebaseCloudMessagingListeners();
    _isInitialized = true;
  }

  static Future<String?> getFcmToken({bool forceRefresh = false}) async {
    _firebaseMessaging ??= FirebaseMessaging.instance;
    final token = forceRefresh
        ? await _firebaseMessaging!.getToken()
        : (await _firebaseMessaging!.getToken()) ?? cachedFcmToken;
    await _cacheFcmToken(token);
    return token;
  }

  static String? get cachedFcmToken =>
      sl<SharedPreferences>().getString(AppStorageKey.fcmToken);

  static Future<void> _cacheFcmToken(String? token) async {
    if (token == null || token.isEmpty) {
      log('FCM token is null or empty');
      return;
    }
    await sl<SharedPreferences>().setString(AppStorageKey.fcmToken, token);
    log('FCM token: $token');
  }

  static Future<void> firebaseCloudMessagingListeners() async {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage data) {
        log('on Message notification ${data.notification?.toMap()}');
        log('on Message data ${data.data}');
        log('on Message body ${data.notification?.body}');
        Map notify = data.data;
        log('$notify');
        if (Platform.isAndroid && data.notification != null) {
          scheduleNotification(
            data.notification!.title ?? '',
            data.notification!.body ?? '',
            json.encode(notify),
          );
        }
        updateUserFunctions(notify: notify);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage data) {
      log('on Opened ${data.data}');
      Map notify = data.data;
      handlePath(notify);
    });

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      log('Data from initial message >>>>>> ${value?.data}');
      if (value != null && value.data.isNotEmpty) {
        handlePath(value.data);
      }
    });

    _notificationsPlugin!.getActiveNotifications().then((value) {
      if (value.isNotEmpty) {
        log('on Opened From ActiveNotifications ${value[0].payload}');
        if (value[0].payload != null && value[0].payload != '') {
          handlePath(json.decode(value[0].payload!));
        }
      }
    });

    _notificationsPlugin!
        .getNotificationAppLaunchDetails()
        .then((NotificationAppLaunchDetails? data) {
      log('on Opened From Notification ${json.decode(json.encode(data?.notificationResponse?.payload.toString()))}');
      final payload = data?.notificationResponse?.payload;
      if ((payload ?? '').isNotEmpty) {
        handlePath(json.decode(payload!));
      }
    });
  }
}
