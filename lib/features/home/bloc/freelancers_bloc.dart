import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/freelancers_repository.dart';
import 'freelancers_event.dart';
import 'freelancers_state.dart';

class FreelancersBloc extends Bloc<FreelancersEvent, FreelancersState> {
  FreelancersBloc({required FreelancersRepository repository})
      : _repository = repository,
        super(const FreelancersInitial()) {
    on<FreelancersRequested>(_onRequested);
  }

  final FreelancersRepository _repository;

  Future<void> _onRequested(
    FreelancersRequested event,
    Emitter<FreelancersState> emit,
  ) async {
    emit(const FreelancersLoading());
    final result = await _repository.getFreelancerList(
      categoryId: event.categoryId,
      search: event.search,
    );
    result.fold(
      (failure) => emit(FreelancersFailed(failure.error)),
      (freelancers) => emit(FreelancersLoaded(freelancers)),
    );
  }
}
