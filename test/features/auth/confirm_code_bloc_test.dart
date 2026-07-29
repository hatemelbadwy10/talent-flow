import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/auth/data/auth_session_store.dart';
import 'package:talent_flow/features/auth/models/auth_response.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/bloc/confirm_code_bloc.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/bloc/confirm_code_event.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/bloc/confirm_code_state.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/model/confirm_code_request.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/model/confirm_code_result.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/repo/confirm_code_repository.dart';

void main() {
  group('ConfirmCodeBloc', () {
    test('persists the authenticated session after registration', () async {
      final sessionStore = _FakeAuthSessionStore();
      final bloc = ConfirmCodeBloc(
        repository: _FakeConfirmCodeRepository(
          result: right(const ConfirmCodeResult(
            message: 'Verified',
            authResponse: _authResponse,
          )),
        ),
        sessionStore: sessionStore,
      );

      bloc.add(const CodeSubmitted(_registrationRequest));
      final state = await bloc.stream.firstWhere(
        (state) => state is ConfirmCodeSucceeded,
      ) as ConfirmCodeSucceeded;

      expect(state.request.flow, ConfirmationFlow.registration);
      expect(sessionStore.persistedSession, isTrue);
      await bloc.close();
    });

    test('does not persist a session for password reset', () async {
      final sessionStore = _FakeAuthSessionStore();
      final bloc = ConfirmCodeBloc(
        repository: _FakeConfirmCodeRepository(
          result: right(const ConfirmCodeResult(message: 'Verified')),
        ),
        sessionStore: sessionStore,
      );

      bloc.add(const CodeSubmitted(ConfirmCodeRequest(
        identifier: 'user@example.com',
        otp: '123456',
        flow: ConfirmationFlow.passwordReset,
      )));
      await bloc.stream.firstWhere((state) => state is ConfirmCodeSucceeded);

      expect(sessionStore.persistedSession, isFalse);
      await bloc.close();
    });

    test('emits the API failure message', () async {
      final bloc = ConfirmCodeBloc(
        repository: _FakeConfirmCodeRepository(
          result: left(ServerFailure('Invalid code')),
        ),
        sessionStore: _FakeAuthSessionStore(),
      );

      bloc.add(const CodeSubmitted(_registrationRequest));
      final state = await bloc.stream.firstWhere(
        (state) => state is ConfirmCodeFailed,
      ) as ConfirmCodeFailed;

      expect(state.message, 'Invalid code');
      await bloc.close();
    });
  });
}

const _registrationRequest = ConfirmCodeRequest(
  identifier: 'user@example.com',
  otp: '123456',
  flow: ConfirmationFlow.registration,
);

const _authResponse = AuthResponse(
  user: {
    'id': 1,
    'first_name': 'Talent',
    'email': 'user@example.com',
    'image': '',
    'user_type': 'Freelancer',
  },
  token: 'token',
  raw: {
    'payload': {
      'user': {
        'id': 1,
        'first_name': 'Talent',
        'email': 'user@example.com',
        'image': '',
        'user_type': 'Freelancer',
      },
      'token': 'token',
    },
  },
);

class _FakeConfirmCodeRepository implements ConfirmCodeRepository {
  _FakeConfirmCodeRepository({required this.result});

  final Either<ServerFailure, ConfirmCodeResult> result;

  @override
  Future<Either<ServerFailure, ConfirmCodeResult>> confirm(
    ConfirmCodeRequest request,
  ) async {
    return result;
  }
}

class _FakeAuthSessionStore implements AuthSessionStore {
  bool persistedSession = false;

  @override
  Future<void> clearAuthenticatedSession() async {}

  @override
  Future<void> persistAuthenticatedSession(AuthResponse response) async {
    persistedSession = true;
  }

  @override
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {}
}
