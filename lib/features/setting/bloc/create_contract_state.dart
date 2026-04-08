import 'package:equatable/equatable.dart';

import '../model/create_contract_page_info_model.dart';

class CreateContractState extends Equatable {
  const CreateContractState({
    this.pageInfo,
    this.isLoadingPageInfo = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final CreateContractPageInfoModel? pageInfo;
  final bool isLoadingPageInfo;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  CreateContractState copyWith({
    CreateContractPageInfoModel? pageInfo,
    bool? isLoadingPageInfo,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CreateContractState(
      pageInfo: pageInfo ?? this.pageInfo,
      isLoadingPageInfo: isLoadingPageInfo ?? this.isLoadingPageInfo,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        pageInfo,
        isLoadingPageInfo,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
