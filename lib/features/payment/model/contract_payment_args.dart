class ContractPaymentRequestArgs {
  const ContractPaymentRequestArgs({
    required this.contractId,
    this.contractTitle,
    this.initialAmount,
    this.initialStartDate,
  });

  final int contractId;
  final String? contractTitle;
  final String? initialAmount;
  final String? initialStartDate;
}

class ContractPaymentConfirmArgs {
  const ContractPaymentConfirmArgs({
    required this.contractId,
    required this.customerNumber,
    required this.paymentCode,
    required this.paymentAmount,
    required this.startDate,
  });

  final int contractId;
  final String customerNumber;
  final String paymentCode;
  final String paymentAmount;
  final String startDate;
}
