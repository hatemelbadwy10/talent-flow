part of 'notification_helper.dart';

FlutterLocalNotificationsPlugin? _notificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel _androidNotificationChannel =
    AndroidNotificationChannel(
  'talent_flow_notifications',
  'Talent Flow Notifications',
  description: 'Notifications for Talent Flow app updates and messages',
  importance: Importance.high,
);

Future<void> localNotification() async {
  _notificationsPlugin = FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    await _notificationsPlugin!
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else {
    await _notificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidNotificationChannel);
  }

  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var ios = const DarwinInitializationSettings(
    defaultPresentBadge: true,
    defaultPresentAlert: true,
    defaultPresentSound: true,
  );
  var initSetting = InitializationSettings(
    android: android,
    iOS: ios,
  );
  await _notificationsPlugin!.initialize(
    initSetting,
    onDidReceiveNotificationResponse: (not) {
      log("onSelect Message ${not.payload}");
      if ((not.payload ?? '').isEmpty) {
        return;
      }
      handlePath(json.decode(not.payload!));
    },
  );
}
