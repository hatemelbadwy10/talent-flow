import '../model/create_contract_request_model.dart';

abstract class CreateContractEvent {
  const CreateContractEvent();
}

class LoadCreateContractPageInfo extends CreateContractEvent {
  const LoadCreateContractPageInfo({required this.projectId});

  final int projectId;
}

class SubmitCreateContract extends CreateContractEvent {
  const SubmitCreateContract({
    required this.request,
    this.contractId,
  });

  final CreateContractRequestModel request;
  final int? contractId;
}

class ClearCreateContractFeedback extends CreateContractEvent {
  const ClearCreateContractFeedback();
}
