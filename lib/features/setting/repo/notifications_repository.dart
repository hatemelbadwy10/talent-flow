import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/notification_model.dart';

abstract interface class NotificationsRepository {
  Future<Either<ServerFailure, List<NotificationModel>>> getNotifications({
    String type,
  });
}
