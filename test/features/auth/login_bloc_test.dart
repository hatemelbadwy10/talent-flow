import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/auth/data/auth_session_store.dart';
import 'package:talent_flow/features/auth/models/auth_response.dart';
import 'package:talent_flow/features/auth/pages/login/bloc/login_bloc.dart';
import 'package:talent_flow/features/auth/pages/login/bloc/login_event.dart';
import 'package:talent_flow/features/auth/pages/login/bloc/login_state.dart';
import 'package:talent_flow/features/auth/pages/login/repo/login_repository.dart';

void main() {
  group('LoginBloc', () {
    test('persists the session and emits success for valid credentials',
        () async {
      final repository = _FakeLoginRepository(
        loginResult: right(_response),
      );
      final sessionStore = _FakeAuthSessionStore();
      final bloc = LoginBloc(
        repository: repository,
        sessionStore: sessionStore,
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LoginLoading>(),
          isA<LoginSucceeded>(),
        ]),
      );

      bloc.add(const LoginSubmitted(
        email: 'user@example.com',
        password: 'secret',
      ));
      await bloc.stream.firstWhere((state) => state is LoginSucceeded);

      expect(sessionStore.savedCredentials, isTrue);
      expect(sessionStore.persistedSession, isTrue);
      await bloc.close();
    });

    test('emits a typed failure for invalid credentials', () async {
      final repository = _FakeLoginRepository(
        loginResult: left(ServerFailure('Invalid credentials')),
      );
      final sessionStore = _FakeAuthSessionStore();
      final bloc = LoginBloc(
        repository: repository,
        sessionStore: sessionStore,
      );

      bloc.add(const LoginSubmitted(
        email: 'user@example.com',
        password: 'wrong-password',
      ));
      final state = await bloc.stream
          .firstWhere((state) => state is LoginFailed) as LoginFailed;

      expect(state.message, 'Invalid credentials');
      expect(sessionStore.persistedSession, isFalse);
      await bloc.close();
    });

    test('requests a code and emits verification-required', () async {
      final repository = _FakeLoginRepository(
        loginResult: left(ServerFailure('Please verify your account')),
      );
      final bloc = LoginBloc(
        repository: repository,
        sessionStore: _FakeAuthSessionStore(),
      );

      bloc.add(const LoginSubmitted(
        email: 'pending@example.com',
        password: 'secret',
      ));
      final state = await bloc.stream.firstWhere(
        (state) => state is LoginVerificationRequired,
      ) as LoginVerificationRequired;

      expect(state.email, 'pending@example.com');
      expect(repository.verificationEmail, 'pending@example.com');
      await bloc.close();
    });
  });
}

const _response = AuthResponse(
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

class _FakeLoginRepository implements LoginRepository {
  _FakeLoginRepository({required this.loginResult});

  final Either<ServerFailure, AuthResponse> loginResult;
  String? verificationEmail;

  @override
  Future<Either<ServerFailure, AuthResponse>> logIn({
    required String email,
    required String password,
  }) async {
    return loginResult;
  }

  @override
  Future<Either<ServerFailure, Unit>> resendVerificationEmail(
    String email,
  ) async {
    verificationEmail = email;
    return right(unit);
  }
}

class _FakeAuthSessionStore implements AuthSessionStore {
  bool savedCredentials = false;
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
  }) async {
    savedCredentials = true;
  }
}
