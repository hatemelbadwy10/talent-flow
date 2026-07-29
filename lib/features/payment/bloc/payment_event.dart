sealed class PaymentEvent {
  const PaymentEvent();
}

final class PaymentMethodsRequested extends PaymentEvent {
  const PaymentMethodsRequested();
}
