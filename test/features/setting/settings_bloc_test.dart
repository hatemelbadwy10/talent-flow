import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/auth/data/auth_session_store.dart';
import 'package:talent_flow/features/auth/models/auth_response.dart';
import 'package:talent_flow/features/setting/bloc/setting_bloc.dart';
import 'package:talent_flow/features/setting/bloc/settings_event.dart';
import 'package:talent_flow/features/setting/bloc/settings_state.dart';
import 'package:talent_flow/features/setting/model/help_model.dart';
import 'package:talent_flow/features/setting/repo/settings_repository.dart';

void main() {
  test('logout clears the persisted session after API success', () async {
    final sessionStore = _FakeAuthSessionStore();
    final bloc = SettingsBloc(
      repository: _FakeSettingsRepository(),
      sessionStore: sessionStore,
    )..add(const LogoutRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is LogoutSucceeded,
    );
    expect(state, isA<LogoutSucceeded>());
    expect(sessionStore.clearCount, 1);
    await bloc.close();
  });

  test('failed account deletion keeps the persisted session', () async {
    final sessionStore = _FakeAuthSessionStore();
    final bloc = SettingsBloc(
      repository: _FakeSettingsRepository(failDelete: true),
      sessionStore: sessionStore,
    )..add(const AccountDeletionRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is SettingsFailed,
    ) as SettingsFailed;
    expect(state.message, 'Delete failed');
    expect(sessionStore.clearCount, 0);
    await bloc.close();
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({this.failDelete = false});

  final bool failDelete;

  @override
  Future<Either<ServerFailure, String>> help(HelpModel model) async {
    return right('Sent');
  }

  @override
  Future<Either<ServerFailure, String>> logout() async {
    return right('Logged out');
  }

  @override
  Future<Either<ServerFailure, String>> deleteAccount() async {
    return failDelete ? left(ServerFailure('Delete failed')) : right('Deleted');
  }
}

class _FakeAuthSessionStore implements AuthSessionStore {
  int clearCount = 0;

  @override
  Future<void> clearAuthenticatedSession() async {
    clearCount++;
  }

  @override
  Future<void> persistAuthenticatedSession(AuthResponse response) async {}

  @override
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {}
}
