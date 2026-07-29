import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/splash/bloc/splash_bloc.dart';
import 'package:talent_flow/features/splash/repo/splash_repository.dart';

void main() {
  test('first launch is marked and routed to onboarding', () async {
    final repository = _FakeSplashRepository(isFirstTime: true);
    final bloc = SplashBloc(
      repository: repository,
      delay: Duration.zero,
    );

    bloc.add(const SplashStarted());
    final state = await bloc.stream.firstWhere((state) => state is SplashReady)
        as SplashReady;

    expect(state.destination, SplashDestination.onboarding);
    expect(repository.onboardingSeen, isTrue);
    await bloc.close();
  });

  test('an authenticated returning user is routed home', () async {
    final bloc = SplashBloc(
      repository: _FakeSplashRepository(isLogin: true),
      delay: Duration.zero,
    );

    bloc.add(const SplashStarted());
    final state = await bloc.stream.firstWhere((state) => state is SplashReady)
        as SplashReady;

    expect(state.destination, SplashDestination.home);
    await bloc.close();
  });

  test('a signed-out returning user is routed to login', () async {
    final bloc = SplashBloc(
      repository: _FakeSplashRepository(),
      delay: Duration.zero,
    );

    bloc.add(const SplashStarted());
    final state = await bloc.stream.firstWhere((state) => state is SplashReady)
        as SplashReady;

    expect(state.destination, SplashDestination.login);
    await bloc.close();
  });
}

class _FakeSplashRepository implements SplashRepository {
  _FakeSplashRepository({
    this.isFirstTime = false,
    this.isLogin = false,
  });

  @override
  final bool isFirstTime;

  @override
  final bool isLogin;

  bool onboardingSeen = false;

  @override
  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
  }
}
