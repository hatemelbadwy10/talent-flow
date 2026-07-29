import 'package:flutter_bloc/flutter_bloc.dart';

import '../send_verification_repo/send_verification_repository.dart';
import 'send_verification_event.dart';
import 'send_verification_state.dart';

class SendVerificationBloc
    extends Bloc<SendVerificationEvent, SendVerificationState> {
  SendVerificationBloc({
    required SendVerificationRepository repository,
  })  : _repository = repository,
        super(const SendVerificationInitial()) {
    on<VerificationRequested>(_onVerificationRequested);
  }

  final SendVerificationRepository _repository;

  Future<void> _onVerificationRequested(
    VerificationRequested event,
    Emitter<SendVerificationState> emit,
  ) async {
    emit(const SendVerificationLoading());
    final result = await _repository.sendVerification(event.identifier);
    result.fold(
      (failure) => emit(SendVerificationFailed(failure.error)),
      (success) => emit(
        SendVerificationSucceeded(
          identifier: event.identifier,
          message: success.message,
        ),
      ),
    );
  }
}
