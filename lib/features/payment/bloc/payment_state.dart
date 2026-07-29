import '../model/model.dart';

sealed class PaymentState {
  const PaymentState();
}

final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

final class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

final class PaymentLoaded extends PaymentState {
  const PaymentLoaded(this.methods);
  final List<PaymentModel> methods;
}

final class PaymentFailed extends PaymentState {
  const PaymentFailed(this.message);
  final String message;
}
