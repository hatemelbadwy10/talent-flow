import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/setting/repo/notifications_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationsRepository _repository;

  NotificationBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationInitial()) {
    on<NotificationsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    NotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await _repository.getNotifications(type: event.type);
    result.fold(
      (failure) => emit(NotificationFailed(failure.error)),
      (notifications) => emit(NotificationLoaded(
        type: event.type,
        notifications: notifications,
      )),
    );
  }
}
