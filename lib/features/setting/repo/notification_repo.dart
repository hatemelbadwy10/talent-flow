import 'package:dartz/dartz.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/notification_model.dart';
import 'notifications_repository.dart';

class NotificationRepo extends BaseRepo implements NotificationsRepository {
  NotificationRepo(
      {required super.sharedPreferences, required super.dioClient});

  @override
  Future<Either<ServerFailure, List<NotificationModel>>> getNotifications({
    String type = '',
  }) async {
    try {
      final response =
          await dioClient.get(uri: "${EndPoints.notifications}$type");
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = data['payload'];
      if (payload is! List) {
        return left(ServerFailure('Notifications payload is invalid'));
      }
      return right(
        payload
            .whereType<Map>()
            .map((item) => NotificationModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
