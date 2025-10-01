import 'dart:developer'; // Import for log
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/features/payment/model/model.dart';
import 'package:talent_flow/features/payment/repo/pay_ment_repo.dart';

import '../../../app/core/app_state.dart';

class PaymentBloc extends Bloc<AppEvent, AppState> {
  final PaymentRepo _paymentRepo;

  PaymentBloc(this._paymentRepo) : super(Start()) {
    // Register the event handler for Add event (or a more specific PaymentEvent if you create one)
    on<Add>(getPayment); // Use 'on' for event mapping in Bloc
  }

  Future<void> getPayment(Add event, Emitter<AppState> emit) async {
    emit(Loading()); // Emit Loading state
    try {
      // Call the repository to fetch payment data
      final result = await _paymentRepo.getPayment();

      // Use fold to handle both success (right) and failure (left) cases
      result.fold(
        (failure) {
          // If there's a failure, log it and emit an Error state
          log('🔴 PaymentBloc Error - Failure: ${failure.error}');
          emit(Error());
        },
        (response) {
          // If successful, process the response
          log("Payment Response data: ${response.data}");

          // Basic validation for the payload
          if (response.data == null || response.data['payload'] == null) {
            log('🔴 PaymentBloc Error: Payload is null or missing.');
            emit(Error());
            return;
          }

          // Extract the list of payment methods from the payload
          final List<PaymentModel> paymentMethods =
              (response.data['payload'] as List)
                  .map((e) => PaymentModel.fromJson(e))
                  .toList();

          // Emit Done state with the fetched list
          emit(Done(list: paymentMethods));
        },
      );
    } catch (e) {
      // Catch any unexpected exceptions during the process
      log('🔴 Error in getPayment: $e');
      emit(Error());
    }
  }
}
