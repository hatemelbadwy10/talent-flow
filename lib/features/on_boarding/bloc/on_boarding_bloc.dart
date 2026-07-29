import 'package:flutter_bloc/flutter_bloc.dart';

sealed class OnboardingEvent {
  const OnboardingEvent();
}

final class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

final class OnboardingPageChanged extends OnboardingEvent {
  const OnboardingPageChanged(this.page);

  final int page;
}

final class OnboardingNextRequested extends OnboardingEvent {
  const OnboardingNextRequested();
}

final class OnboardingState {
  const OnboardingState(this.currentPage);

  final int currentPage;
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({this.totalPages = 3}) : super(const OnboardingState(0)) {
    on<OnboardingStarted>((event, emit) {
      emit(const OnboardingState(0));
    });
    on<OnboardingPageChanged>((event, emit) {
      emit(OnboardingState(event.page));
    });
    on<OnboardingNextRequested>((event, emit) {
      if (state.currentPage < totalPages - 1) {
        emit(OnboardingState(state.currentPage + 1));
      }
    });
  }

  final int totalPages;
}
