part of 'notification_helper.dart';


@pragma('vm:entry-point')
scheduleNotification(String title, String subtitle, String data) async {
  var rng = math.Random();
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'channel_id',
    'your channel name',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
    icon: '@mipmap/ic_launcher',
  );
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await _notificationsPlugin!.show(
    rng.nextInt(100000),
    title,
    subtitle,
    platformChannelSpecifics,
    payload: data,
  );
}

void iOSPermission() {
  _firebaseMessaging!.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

void handlePath(Map dataMap) {
  updateUserFunctions(notify: dataMap);
  handlePathByRoute(dataMap);
}

updateUserFunctions({required notify}) async {
  // Future.delayed(Duration.zero, () {
  //   if (UserBloc.instance.isLogin) {
  //     // sl<NotificationsBloc>().add(Get(arguments: SearchEngine()));
  //   }
  // });
}

Future<void> handlePathByRoute(Map notify) async {
  Future.delayed(
    Duration.zero,
    () {
      if (sl<UserBloc>().isLogin) {
        CustomNavigator.push(Routes.notifications);
      }
    },
  );
}
