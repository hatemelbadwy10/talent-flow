import 'dart:developer'; // Import for log
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/payment/repo/pay_ment_repo.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepo _paymentRepo;

  PaymentBloc(this._paymentRepo) : super(const PaymentInitial()) {
    on<PaymentMethodsRequested>(getPayment);
  }

  Future<void> getPayment(
    PaymentMethodsRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final result = await _paymentRepo.getPayment();

      result.fold(
        (failure) {
          log('🔴 PaymentBloc Error - Failure: ${failure.error}');
          emit(PaymentFailure(failure.error));
        },
        (paymentMethods) {
          emit(PaymentMethodsLoaded(paymentMethods));
        },
      );
    } catch (e) {
      log('🔴 Error in getPayment: $e');
      emit(PaymentFailure(e.toString()));
    }
  }
}
