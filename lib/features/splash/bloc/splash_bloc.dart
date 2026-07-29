import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/splash_repository.dart';

final class SplashStarted {
  const SplashStarted();
}

enum SplashDestination { onboarding, login, home }

sealed class SplashState {
  const SplashState();
}

final class SplashWaiting extends SplashState {
  const SplashWaiting();
}

final class SplashReady extends SplashState {
  const SplashReady(this.destination);

  final SplashDestination destination;
}

class SplashBloc extends Bloc<SplashStarted, SplashState> {
  SplashBloc({
    required SplashRepository repository,
    this.delay = const Duration(milliseconds: 2200),
  })  : _repository = repository,
        super(const SplashWaiting()) {
    on<SplashStarted>(_onStarted);
  }

  final SplashRepository _repository;
  final Duration delay;

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    await Future<void>.delayed(delay);
    if (_repository.isFirstTime) {
      await _repository.markOnboardingSeen();
      emit(const SplashReady(SplashDestination.onboarding));
      return;
    }
    emit(
      SplashReady(
        _repository.isLogin ? SplashDestination.home : SplashDestination.login,
      ),
    );
  }
}
