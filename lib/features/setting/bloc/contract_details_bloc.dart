import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/contracts_repository.dart';
import 'contract_details_event.dart';
import 'contract_details_state.dart';

class ContractDetailsBloc
    extends Bloc<ContractDetailsEvent, ContractDetailsState> {
  ContractDetailsBloc({required ContractsReadRepository repository})
      : _repository = repository,
        super(const ContractDetailsInitial()) {
    on<ContractDetailsRequested>(_onRequested);
  }

  final ContractsReadRepository _repository;

  Future<void> _onRequested(
    ContractDetailsRequested event,
    Emitter<ContractDetailsState> emit,
  ) async {
    emit(const ContractDetailsLoading());
    final result = await _repository.getContractDetails(event.contractId);
    result.fold(
      (failure) => emit(ContractDetailsFailed(failure.error)),
      (contract) => emit(ContractDetailsLoaded(contract)),
    );
  }
}
