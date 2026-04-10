import 'dart:developer';

import 'package:talent_flow/app/notifications/notification_helper.dart';
import 'package:talent_flow/data/api/end_points.dart';
import 'package:talent_flow/data/dio/dio_client.dart';

Future<void> syncAuthenticatedDeviceToken(DioClient dioClient) async {
  try {
    final deviceToken = await FirebaseNotifications.getFcmToken();
    if (deviceToken == null || deviceToken.isEmpty) {
      log('Skipping device token update because FCM token is empty.');
      return;
    }

    await dioClient.post(
      uri: EndPoints.updateDeviceToken,
      data: {
        'device_token': deviceToken,
      },
    );
    log('Device token updated successfully.');
  } catch (error) {
    log('Device token update failed: $error');
  }
}
