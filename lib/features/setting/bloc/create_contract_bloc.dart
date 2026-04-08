import 'package:talent_flow/app/core/app_currency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/create_contract_page_info_model.dart';
import '../repo/contracts_repo.dart';
import 'create_contract_event.dart';
import 'create_contract_state.dart';

class CreateContractBloc
    extends Bloc<CreateContractEvent, CreateContractState> {
  CreateContractBloc(this._repo) : super(const CreateContractState()) {
    on<LoadCreateContractPageInfo>(_onLoadPageInfo);
    on<SubmitCreateContract>(_onSubmit);
    on<ClearCreateContractFeedback>(_onClearFeedback);
  }

  final ContractsRepo _repo;

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

    final result = await _repo.getCreateContractPageInfo(event.projectId);
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
      (response) {
        final data = response.data;
        final payload = data is Map<String, dynamic> ? data['payload'] : null;
        if (payload is! Map<String, dynamic>) {
          emit(
            state.copyWith(
              isLoadingPageInfo: false,
              errorMessage: 'Invalid contract page info response',
              clearSuccess: true,
            ),
          );
          return;
        }

        final pageInfo = CreateContractPageInfoModel.fromJson(payload);
        AppCurrency.cache(pageInfo.currency);

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
        ? await _repo.createContract(event.request)
        : await _repo.updateContract(
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
      (response) {
        final message = response.data is Map && response.data['message'] != null
            ? response.data['message'].toString()
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
