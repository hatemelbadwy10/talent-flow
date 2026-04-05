import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

import '../repo/home_repo.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepo _homeRepo;

  HomeBloc({required HomeRepo homeRepo})
      : _homeRepo = homeRepo,
        super(const HomeInitial()) {
    on<HomeRequested>(_onGetHomeData);
    on<HomeCategoriesRequested>(_onGetCategories);
    on<HomeFreelancersRequested>(_onGetFreelancers);
    on<FreelancerProfileRequested>(_onGetFreelancerProfile);
    on<EntrepreneurProfileRequested>(_onGetEntrepreneurProfile);
    on<WorkDetailsRequested>(_onGetWorkDetails);
  }

  Future<void> _onGetHomeData(
    HomeRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final result = await _homeRepo.getHome();

      result.fold(
        (failure) {
          log('HomeBloc home feed failure: ${failure.error}');
          emit(HomeFailure(message: failure.error));
        },
        (homeModel) {
          emit(HomeFeedLoaded(homeModel));
        },
      );
    } catch (e, stackTrace) {
      log('Unexpected error in _onGetHomeData: $e');
      log('Stack trace: $stackTrace');
      emit(HomeFailure(message: e.toString()));
    }
  }

  Future<void> _onGetCategories(
    HomeCategoriesRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final result = await _homeRepo.getCategories();

      result.fold(
        (failure) {
          emit(HomeFailure(message: failure.error));
        },
        (categories) {
          emit(HomeCategoriesLoaded(categories));
        },
      );
    } catch (e, stackTrace) {
      log('Unexpected error in _onGetCategories: $e');
      log('Stack trace: $stackTrace');
      emit(HomeFailure(message: e.toString()));
    }
  }

  Future<void> _onGetFreelancers(
    HomeFreelancersRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final result =
          await _homeRepo.getFreelancers(categoryId: event.categoryId);

      result.fold(
        (failure) => emit(HomeFailure(message: failure.error)),
        (freelancers) => emit(HomeFreelancersLoaded(freelancers)),
      );
    } catch (e, s) {
      log("Error in _onGetFreelancers: $e\n$s");
      emit(HomeFailure(message: e.toString()));
    }
  }

  Future<void> _onGetFreelancerProfile(
    FreelancerProfileRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final result = await _homeRepo.getFreelancerProfile(event.freelancerId);
      result.fold(
        (failure) => emit(HomeFailure(message: failure.error)),
        (profile) => emit(FreelancerProfileLoaded(profile)),
      );
    } catch (e, s) {
      log("Error in _onGetFreelancerProfile: $e\n$s");
      emit(HomeFailure(message: e.toString()));
    }
  }

  Future<void> _onGetEntrepreneurProfile(
    EntrepreneurProfileRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final result =
          await _homeRepo.getEntrepreneurProfile(event.entrepreneurId);
      result.fold(
        (failure) => emit(HomeFailure(message: failure.error)),
        (profile) => emit(EntrepreneurProfileLoaded(profile)),
      );
    } catch (e, s) {
      log("Error in _onGetEntrepreneurProfile: $e\n$s");
      emit(HomeFailure(message: e.toString()));
    }
  }

  Future<void> _onGetWorkDetails(
    WorkDetailsRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final result = await _homeRepo.getWorkDetails(event.workId);
      result.fold(
        (failure) => emit(HomeFailure(message: failure.error)),
        (work) => emit(WorkDetailsLoaded(work)),
      );
    } catch (e, s) {
      log("Error in _onGetWorkDetails: $e\n$s");
      emit(HomeFailure(message: e.toString()));
    }
  }
}
