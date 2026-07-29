sealed class ContractDetailsEvent {
  const ContractDetailsEvent();
}

final class ContractDetailsRequested extends ContractDetailsEvent {
  const ContractDetailsRequested(this.contractId);
  final int contractId;
}
