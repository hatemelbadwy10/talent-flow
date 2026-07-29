import '../model/contract_model.dart';

sealed class ContractDetailsState {
  const ContractDetailsState();
}

final class ContractDetailsInitial extends ContractDetailsState {
  const ContractDetailsInitial();
}

final class ContractDetailsLoading extends ContractDetailsState {
  const ContractDetailsLoading();
}

final class ContractDetailsLoaded extends ContractDetailsState {
  const ContractDetailsLoaded(this.contract);
  final ContractModel contract;
}

final class ContractDetailsFailed extends ContractDetailsState {
  const ContractDetailsFailed(this.message);
  final String message;
}
