import 'package:equatable/equatable.dart';
import 'package:talent_flow/features/payment/model/model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentFailure extends PaymentState {
  const PaymentFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class PaymentMethodsLoaded extends PaymentState {
  const PaymentMethodsLoaded(this.methods);

  final List<PaymentModel> methods;

  @override
  List<Object?> get props => [methods];
}
