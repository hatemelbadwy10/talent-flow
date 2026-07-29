import '../model/notification_model.dart';

sealed class NotificationState {
  const NotificationState();
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required this.type,
    required this.notifications,
  });
  final String type;
  final List<NotificationModel> notifications;
}

final class NotificationFailed extends NotificationState {
  const NotificationFailed(this.message);
  final String message;
}
