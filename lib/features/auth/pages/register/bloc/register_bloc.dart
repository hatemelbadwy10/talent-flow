import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/register_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required RegisterRepository repository})
      : _repository = repository,
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  final RegisterRepository _repository;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());
    final result = await _repository.register(event.request);
    result.fold(
      (failure) => emit(RegisterFailed(failure.error)),
      (_) => emit(RegisterSucceeded(event.request.email)),
    );
  }
}
