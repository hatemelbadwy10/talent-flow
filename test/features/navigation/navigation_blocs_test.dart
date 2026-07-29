import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/nav_bar/bloc/nav_bar_bloc.dart';
import 'package:talent_flow/features/on_boarding/bloc/on_boarding_bloc.dart';

void main() {
  test('NavBarBloc emits a typed selected index', () async {
    final bloc = NavBarBloc();

    bloc.add(const NavBarSelectionChanged(1));
    final state = await bloc.stream.first;

    expect(state.selectedIndex, 1);
    await bloc.close();
  });

  test('OnboardingBloc advances without exceeding the final page', () async {
    final bloc = OnboardingBloc(totalPages: 2);

    bloc
      ..add(const OnboardingNextRequested())
      ..add(const OnboardingNextRequested());
    final states = await bloc.stream.take(1).toList();

    expect(states.single.currentPage, 1);
    await bloc.close();
  });
}
