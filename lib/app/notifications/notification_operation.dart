part of 'notification_helper.dart';

@pragma('vm:entry-point')
scheduleNotification(String title, String subtitle, String data) async {
  var rng = math.Random();
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'talent_flow_notifications',
    'Talent Flow Notifications',
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
      if (!sl<UserBloc>().isLogin) {
        return;
      }

      final type = notify['type']?.toString().trim().toLowerCase();
      final id = _parseNotificationId(notify['id']);
      final projectId = _parseNotificationId(
        notify['project_id'] ?? notify['projectId'] ?? notify['id'],
      );

      switch (type) {
        case 'project':
          if (id != null) {
            CustomNavigator.push(
              Routes.singleProjectDetails,
              arguments: {'id': id},
            );
            return;
          }
          break;
        case 'contract':
          if (id != null) {
            CustomNavigator.push(Routes.contractDetails, arguments: id);
            return;
          }
          break;
        case 'conversation':
          if (id != null) {
            CustomNavigator.push(
              Routes.chat,
              arguments: {
                'conversationId': id,
                if (projectId != null) 'project_id': projectId,
                if (projectId != null) 'projectId': projectId,
              },
            );
            return;
          }
          break;
      }

      CustomNavigator.push(Routes.notifications);
    },
  );
}

int? _parseNotificationId(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '');
}
