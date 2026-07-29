import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/auth/data/auth_session_store.dart';
import 'package:talent_flow/features/auth/models/auth_response.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/bloc/social_media_bloc.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/bloc/social_media_event.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/bloc/social_media_state.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/repo/social_media_repository.dart';
import 'package:talent_flow/helpers/social_media_login_helper.dart';

void main() {
  group('SocialMediaBloc', () {
    test('persists the session and emits success', () async {
      final sessionStore = _FakeAuthSessionStore();
      final repository = _FakeSocialMediaRepository(right(_response));
      final bloc = SocialMediaBloc(
        repository: repository,
        sessionStore: sessionStore,
        isFreelancer: true,
      );

      bloc.add(
        const SocialSignInRequested(SocialMediaProvider.google),
      );
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SocialMediaLoading>(),
          isA<SocialMediaSucceeded>(),
        ]),
      );

      expect(repository.isFreelancer, isTrue);
      expect(repository.provider, SocialMediaProvider.google);
      expect(sessionStore.persistedSession, isTrue);
      await bloc.close();
    });

    test('emits failure without persisting the session', () async {
      final sessionStore = _FakeAuthSessionStore();
      final bloc = SocialMediaBloc(
        repository: _FakeSocialMediaRepository(
          left(ServerFailure('Social login failed')),
        ),
        sessionStore: sessionStore,
        isFreelancer: false,
      );

      bloc.add(
        const SocialSignInRequested(SocialMediaProvider.apple),
      );
      final state = await bloc.stream.firstWhere(
        (state) => state is SocialMediaFailed,
      ) as SocialMediaFailed;

      expect(state.message, 'Social login failed');
      expect(sessionStore.persistedSession, isFalse);
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

class _FakeSocialMediaRepository implements SocialMediaRepository {
  _FakeSocialMediaRepository(this.result);

  final Either<ServerFailure, AuthResponse> result;
  SocialMediaProvider? provider;
  bool? isFreelancer;

  @override
  Future<Either<ServerFailure, AuthResponse>> signInWithSocialMedia({
    required SocialMediaProvider provider,
    required bool isFreelancer,
  }) async {
    this.provider = provider;
    this.isFreelancer = isFreelancer;
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
