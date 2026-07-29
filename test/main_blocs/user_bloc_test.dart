import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/data/realtime/user_subscription_controller.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/main_models/user_model.dart';
import 'package:talent_flow/main_repos/user_repository.dart';

void main() {
  group('UserBloc', () {
    test('loads the remote user into a typed state', () async {
      final repository = _FakeUserRepository(remoteUser: _user);
      final bloc = UserBloc(
        repository: repository,
        subscriptionController: _FakeSubscriptionController(),
      );

      bloc.add(const UserRequested());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          isA<UserLoaded>(),
        ]),
      );

      expect(bloc.user?.id, 1);
      await bloc.close();
    });

    test('falls back to the persisted user after a network failure', () async {
      final repository = _FakeUserRepository(
        remoteFailure: ServerFailure('Offline'),
        localUser: _user,
      );
      final bloc = UserBloc(
        repository: repository,
        subscriptionController: _FakeSubscriptionController(),
      );

      bloc.add(const UserRequested());
      final state =
          await bloc.stream.firstWhere((state) => state is UserLoaded);

      expect(state.user?.name, 'Talent User');
      await bloc.close();
    });

    test('clears persistence and the realtime subscription', () async {
      final repository = _FakeUserRepository(remoteUser: _user);
      final subscriptions = _FakeSubscriptionController();
      final bloc = UserBloc(
        repository: repository,
        subscriptionController: subscriptions,
      );

      bloc.add(const UserCleared());
      await bloc.stream.firstWhere((state) => state is UserInitial);

      expect(repository.wasCleared, isTrue);
      expect(subscriptions.wasCleared, isTrue);
      await bloc.close();
    });
  });
}

final _user = UserModel.fromJson({
  'id': 1,
  'name': 'Talent User',
  'email': 'user@example.com',
});

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({
    this.remoteUser,
    this.localUser,
    this.remoteFailure,
  });

  final UserModel? remoteUser;
  final UserModel? localUser;
  final ServerFailure? remoteFailure;
  bool wasCleared = false;

  @override
  bool get isLogIn => true;

  @override
  Future<Either<ServerFailure, UserModel>> fetchUserProfile() async {
    if (remoteFailure != null) {
      return left(remoteFailure!);
    }
    return right(remoteUser!);
  }

  @override
  Either<ServerFailure, UserModel> getUser() {
    return localUser == null
        ? left(ServerFailure('No local user'))
        : right(localUser!);
  }

  @override
  Future<void> clearUserData() async {
    wasCleared = true;
  }

  @override
  Future<void> setUserData(Map<String, dynamic> json) async {}

  @override
  UserModel? updateUnreadCounts({int? notifications, int? messages}) {
    return remoteUser ?? localUser;
  }
}

class _FakeSubscriptionController implements UserSubscriptionController {
  bool wasCleared = false;

  @override
  Future<void> clearSubscription() async {
    wasCleared = true;
  }
}
