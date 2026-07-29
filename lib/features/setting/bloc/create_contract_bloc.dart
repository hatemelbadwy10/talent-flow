import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/contracts_repository.dart';
import 'create_contract_event.dart';
import 'create_contract_state.dart';

class CreateContractBloc
    extends Bloc<CreateContractEvent, CreateContractState> {
  CreateContractBloc({required ContractsRepository repository})
      : _repository = repository,
        super(const CreateContractState()) {
    on<LoadCreateContractPageInfo>(_onLoadPageInfo);
    on<SubmitCreateContract>(_onSubmit);
    on<ClearCreateContractFeedback>(_onClearFeedback);
  }

  final ContractsRepository _repository;

  Future<void> _onLoadPageInfo(
    LoadCreateContractPageInfo event,
    Emitter<CreateContractState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingPageInfo: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _repository.getCreateContractPageInfo(event.projectId);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoadingPageInfo: false,
            errorMessage: failure.error,
            clearSuccess: true,
          ),
        );
      },
      (pageInfo) {
        emit(
          state.copyWith(
            pageInfo: pageInfo,
            isLoadingPageInfo: false,
            clearError: true,
            clearSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onSubmit(
    SubmitCreateContract event,
    Emitter<CreateContractState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = event.contractId == null
        ? await _repository.createContract(event.request)
        : await _repository.updateContract(
            contractId: event.contractId!,
            request: event.request,
          );
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: failure.error,
            clearSuccess: true,
          ),
        );
      },
      (serverMessage) {
        final message = serverMessage.trim().isNotEmpty
            ? serverMessage
            : event.contractId == null
                ? 'Contract created successfully'
                : 'Contract updated successfully';
        emit(
          state.copyWith(
            isSubmitting: false,
            clearError: true,
            successMessage: message,
          ),
        );
      },
    );
  }

  void _onClearFeedback(
    ClearCreateContractFeedback event,
    Emitter<CreateContractState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}
