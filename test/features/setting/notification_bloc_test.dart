import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/notification_bloc.dart';
import 'package:talent_flow/features/setting/bloc/notification_event.dart';
import 'package:talent_flow/features/setting/bloc/notification_state.dart';
import 'package:talent_flow/features/setting/model/notification_model.dart';
import 'package:talent_flow/features/setting/repo/notifications_repository.dart';

void main() {
  test('NotificationBloc forwards the notification type', () async {
    final repository = _FakeNotificationsRepository();
    final bloc = NotificationBloc(repository: repository)
      ..add(const NotificationsRequested(type: 'payments'));

    final state = await bloc.stream.firstWhere(
      (state) => state is NotificationLoaded,
    ) as NotificationLoaded;
    expect(repository.type, 'payments');
    expect(state.type, 'payments');
    expect(state.notifications, same(repository.notifications));
    await bloc.close();
  });

  test('NotificationBloc exposes repository failures', () async {
    final bloc = NotificationBloc(
      repository: _FakeNotificationsRepository(fail: true),
    )..add(const NotificationsRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is NotificationFailed,
    ) as NotificationFailed;
    expect(state.message, 'Notifications failed');
    await bloc.close();
  });
}

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({this.fail = false});

  final bool fail;
  final notifications = <NotificationModel>[
    NotificationModel.fromJson(const {'id': 1}),
  ];
  String? type;

  @override
  Future<Either<ServerFailure, List<NotificationModel>>> getNotifications({
    String type = '',
  }) async {
    this.type = type;
    return fail
        ? left(ServerFailure('Notifications failed'))
        : right(notifications);
  }
}
