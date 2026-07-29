sealed class NotificationEvent {
  const NotificationEvent();
}

final class NotificationsRequested extends NotificationEvent {
  const NotificationsRequested({this.type = ''});
  final String type;
}
