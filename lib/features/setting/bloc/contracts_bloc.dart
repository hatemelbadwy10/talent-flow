import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/contracts_repository.dart';
import 'contracts_event.dart';
import 'contracts_state.dart';

class ContractsBloc extends Bloc<ContractsEvent, ContractsState> {
  ContractsBloc({required ContractsRepository repository})
      : _repository = repository,
        super(const ContractsInitial()) {
    on<ContractsRequested>(_onRequested);
  }

  final ContractsRepository _repository;

  Future<void> _onRequested(
    ContractsRequested event,
    Emitter<ContractsState> emit,
  ) async {
    emit(const ContractsLoading());
    final result = await _repository.getContracts();
    result.fold(
      (failure) => emit(ContractsFailed(failure.error)),
      (contracts) => emit(ContractsLoaded(contracts)),
    );
  }
}
