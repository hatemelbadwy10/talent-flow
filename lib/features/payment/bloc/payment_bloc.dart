import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/payment/repo/payment_repository.dart';

import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;

  PaymentBloc({required PaymentRepository repository})
      : _repository = repository,
        super(const PaymentInitial()) {
    on<PaymentMethodsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PaymentMethodsRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _repository.getPaymentMethods();
    result.fold(
      (failure) => emit(PaymentFailed(failure.error)),
      (methods) => emit(PaymentLoaded(methods)),
    );
  }
}
