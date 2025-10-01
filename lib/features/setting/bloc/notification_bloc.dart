import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/setting/repo/notification_repo.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../model/notification_model.dart';

class NotificationBloc extends Bloc<AppEvent, AppState> {
  final NotificationRepo _notificationRepo;

  NotificationBloc(this._notificationRepo) : super(Start()) {
    on<Add>(_onGetNotifications);
  }

  Future<void> _onGetNotifications(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final type = (event.arguments is String) ? event.arguments as String : "";
      final result = await _notificationRepo.getNotification(type: type);

      result.fold(
            (failure) {
          log("Notification error: $failure");
          emit(Error());
        },
            (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }

          final List<NotificationModel> notifications =
          (response.data['payload'] as List)
              .map((e) => NotificationModel.fromJson(e))
              .toList();

          log("Fetched ${notifications.length} notifications of type: $type");

          emit(Done(list: notifications));
        },
      );
    } catch (e, s) {
      log("Exception in NotificationBloc", error: e, stackTrace: s);
      emit(Error());
    }
  }
}
