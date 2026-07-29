import '../model/contract_model.dart';

sealed class ContractsState {
  const ContractsState();
}

final class ContractsInitial extends ContractsState {
  const ContractsInitial();
}

final class ContractsLoading extends ContractsState {
  const ContractsLoading();
}

final class ContractsLoaded extends ContractsState {
  const ContractsLoaded(this.contracts);
  final List<ContractModel> contracts;
}

final class ContractsFailed extends ContractsState {
  const ContractsFailed(this.message);
  final String message;
}
