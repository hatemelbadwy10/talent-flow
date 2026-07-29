import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/entrepreneur_profile_model.dart';
import '../repo/entrepreneur_profile_repository.dart';

sealed class EntrepreneurProfileEvent {
  const EntrepreneurProfileEvent();
}

final class EntrepreneurProfileRequested extends EntrepreneurProfileEvent {
  const EntrepreneurProfileRequested(this.id);
  final int id;
}

sealed class EntrepreneurProfileState {
  const EntrepreneurProfileState();
}

final class EntrepreneurProfileInitial extends EntrepreneurProfileState {
  const EntrepreneurProfileInitial();
}

final class EntrepreneurProfileLoading extends EntrepreneurProfileState {
  const EntrepreneurProfileLoading();
}

final class EntrepreneurProfileLoaded extends EntrepreneurProfileState {
  const EntrepreneurProfileLoaded(this.profile);
  final EntrepreneurProfileModel profile;
}

final class EntrepreneurProfileFailed extends EntrepreneurProfileState {
  const EntrepreneurProfileFailed(this.message);
  final String message;
}

class EntrepreneurProfileBloc
    extends Bloc<EntrepreneurProfileEvent, EntrepreneurProfileState> {
  EntrepreneurProfileBloc({
    required EntrepreneurProfileRepository repository,
  })  : _repository = repository,
        super(const EntrepreneurProfileInitial()) {
    on<EntrepreneurProfileRequested>(_onRequested);
  }

  final EntrepreneurProfileRepository _repository;

  Future<void> _onRequested(
    EntrepreneurProfileRequested event,
    Emitter<EntrepreneurProfileState> emit,
  ) async {
    emit(const EntrepreneurProfileLoading());
    final result = await _repository.getEntrepreneur(event.id);
    result.fold(
      (failure) => emit(EntrepreneurProfileFailed(failure.error)),
      (profile) => emit(EntrepreneurProfileLoaded(profile)),
    );
  }
}
