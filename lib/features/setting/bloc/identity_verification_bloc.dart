import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/identity_verification_repository.dart';
import 'identity_verification_event.dart';
import 'identity_verification_state.dart';

class IdentityVerificationBloc
    extends Bloc<IdentityVerificationEvent, IdentityVerificationState> {
  IdentityVerificationBloc({
    required IdentityVerificationRepository repository,
  })  : _repository = repository,
        super(const IdentityVerificationInitial()) {
    on<IdentityVerificationSubmitted>(_onSubmitted);
  }

  final IdentityVerificationRepository _repository;

  Future<void> _onSubmitted(
    IdentityVerificationSubmitted event,
    Emitter<IdentityVerificationState> emit,
  ) async {
    emit(const IdentityVerificationSubmitting());
    final result = await _repository.submitIdentityVerification(event.request);
    result.fold(
      (failure) => emit(IdentityVerificationFailed(failure.error)),
      (message) => emit(IdentityVerificationSucceeded(message)),
    );
  }
}
