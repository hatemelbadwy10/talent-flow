import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/error/failures.dart';
import '../model/bank_accounts_response_model.dart';
import '../repo/bank_accounts_repository.dart';
import 'bank_accounts_event.dart';
import 'bank_accounts_state.dart';

class BankAccountsBloc extends Bloc<BankAccountsEvent, BankAccountsState> {
  BankAccountsBloc({required BankAccountsRepository repository})
      : _repository = repository,
        super(const BankAccountsState()) {
    on<FetchBankAccounts>(_onFetchBankAccounts);
    on<AddBankAccount>(_onAddBankAccount);
    on<UpdateBankAccount>(_onUpdateBankAccount);
    on<DeleteBankAccount>(_onDeleteBankAccount);
  }

  final BankAccountsRepository _repository;

  Future<void> _onFetchBankAccounts(
    FetchBankAccounts event,
    Emitter<BankAccountsState> emit,
  ) async {
    if (event.showLoading) {
      emit(
        state.copyWith(
          isLoading: true,
          clearError: true,
          clearSuccess: true,
        ),
      );
    }

    final accountsResult = await _repository.getBankAccounts();
    final banksResult = await _repository.getBanksOptions();

    accountsResult.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            isSubmitting: false,
            errorMessage: failure.error,
            clearSuccess: true,
          ),
        );
      },
      (accountsResponse) {
        banksResult.fold(
          (failure) {
            emit(
              state.copyWith(
                accounts: accountsResponse.items,
                isLoading: false,
                isSubmitting: false,
                errorMessage: failure.error,
                clearSuccess: true,
              ),
            );
          },
          (banksResponse) {
            emit(
              state.copyWith(
                accounts: accountsResponse.items,
                bankOptions: banksResponse.options,
                isLoading: false,
                isSubmitting: false,
                clearError: true,
                clearSuccess: true,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onAddBankAccount(
    AddBankAccount event,
    Emitter<BankAccountsState> emit,
  ) async {
    await _mutate(
      emit: emit,
      mutation: () => _repository.addBankAccount(request: event.request),
      fallbackSuccessMessage: 'Bank account added successfully',
    );
  }

  Future<void> _onUpdateBankAccount(
    UpdateBankAccount event,
    Emitter<BankAccountsState> emit,
  ) async {
    await _mutate(
      emit: emit,
      mutation: () => _repository.updateBankAccount(request: event.request),
      fallbackSuccessMessage: 'Bank account updated successfully',
    );
  }

  Future<void> _onDeleteBankAccount(
    DeleteBankAccount event,
    Emitter<BankAccountsState> emit,
  ) async {
    await _mutate(
      emit: emit,
      mutation: () => _repository.deleteBankAccount(id: event.id),
      fallbackSuccessMessage: 'Bank account deleted successfully',
    );
  }

  Future<void> _mutate({
    required Emitter<BankAccountsState> emit,
    required Future<Either<ServerFailure, BankAccountMutationResponseModel>>
            Function()
        mutation,
    required String fallbackSuccessMessage,
  }) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await mutation();
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: failure.error,
            clearSuccess: true,
          ),
        );
      },
      (response) async {
        final refreshResult = await _repository.getBankAccounts();
        refreshResult.fold(
          (failure) {
            emit(
              state.copyWith(
                isSubmitting: false,
                errorMessage: failure.error,
                clearSuccess: true,
              ),
            );
          },
          (refreshedResponse) {
            emit(
              state.copyWith(
                accounts: refreshedResponse.items,
                isSubmitting: false,
                clearError: true,
                successMessage: response.message ?? fallbackSuccessMessage,
              ),
            );
          },
        );
      },
    );
  }
}
