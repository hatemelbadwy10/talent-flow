import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/freelancer_profile_repository.dart';
import 'freelancer_profile_event.dart';
import 'freelancer_profile_state.dart';

class FreelancerProfileBloc
    extends Bloc<FreelancerProfileEvent, FreelancerProfileState> {
  FreelancerProfileBloc({required FreelancerProfileRepository repository})
      : _repository = repository,
        super(const FreelancerProfileInitial()) {
    on<FreelancerProfileRequested>(_onRequested);
  }

  final FreelancerProfileRepository _repository;

  Future<void> _onRequested(
    FreelancerProfileRequested event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    emit(const FreelancerProfileLoading());
    final result = await _repository.getProfile(event.id);
    result.fold(
      (failure) => emit(FreelancerProfileFailed(failure.error)),
      (profile) => emit(FreelancerProfileLoaded(profile)),
    );
  }
}
