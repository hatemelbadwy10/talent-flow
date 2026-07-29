import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/auth_session_store.dart';
import '../repo/social_media_repository.dart';
import 'social_media_event.dart';
import 'social_media_state.dart';

class SocialMediaBloc extends Bloc<SocialMediaEvent, SocialMediaState> {
  SocialMediaBloc({
    required SocialMediaRepository repository,
    required AuthSessionStore sessionStore,
    required bool isFreelancer,
  })  : _repository = repository,
        _sessionStore = sessionStore,
        _isFreelancer = isFreelancer,
        super(const SocialMediaInitial()) {
    on<SocialSignInRequested>(_onRequested);
  }

  final SocialMediaRepository _repository;
  final AuthSessionStore _sessionStore;
  final bool _isFreelancer;

  Future<void> _onRequested(
    SocialSignInRequested event,
    Emitter<SocialMediaState> emit,
  ) async {
    emit(const SocialMediaLoading());
    final result = await _repository.signInWithSocialMedia(
      provider: event.provider,
      isFreelancer: _isFreelancer,
    );
    await result.fold(
      (failure) async => emit(SocialMediaFailed(failure.error)),
      (response) async {
        await _sessionStore.persistAuthenticatedSession(response);
        emit(const SocialMediaSucceeded());
      },
    );
  }
}
