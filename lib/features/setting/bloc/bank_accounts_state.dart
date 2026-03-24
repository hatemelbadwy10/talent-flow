import 'package:equatable/equatable.dart';

import '../model/bank_accounts_response_model.dart';

class BankAccountsState extends Equatable {
  const BankAccountsState({
    this.accounts = const [],
    this.bankOptions = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<BankAccountModel> accounts;
  final List<BankOptionModel> bankOptions;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  BankAccountsState copyWith({
    List<BankAccountModel>? accounts,
    List<BankOptionModel>? bankOptions,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BankAccountsState(
      accounts: accounts ?? this.accounts,
      bankOptions: bankOptions ?? this.bankOptions,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        accounts,
        bankOptions,
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
