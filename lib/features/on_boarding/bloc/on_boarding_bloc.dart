import 'package:flutter_bloc/flutter_bloc.dart';
import 'on_boarding_event.dart';
import 'on_boarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  // عدد الصفحات الإجمالي، قد ترغب في تمريره من الخارج لاحقًا
  final int totalPages = 3;

  OnboardingBloc() : super(const OnboardingState(currentPage: 0)) {
    on<OnboardingStarted>((event, emit) {
      emit(const OnboardingState(currentPage: 0));
    });

    on<OnboardingPageChanged>((event, emit) {
      emit(OnboardingState(currentPage: event.page));
    });

    on<OnboardingNextRequested>((event, emit) {
      final currentPage = state.currentPage;
      if (currentPage < totalPages - 1) {
        emit(OnboardingState(currentPage: currentPage + 1));
      }
    });
  }
}
