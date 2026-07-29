import 'contract_model.dart';

final class CreateContractRouteArgs {
  const CreateContractRouteArgs({
    this.projectId,
    this.conversationId,
    this.freelancerId,
    this.contractId,
    this.contract,
  });

  final int? projectId;
  final int? conversationId;
  final int? freelancerId;
  final int? contractId;
  final ContractModel? contract;

  factory CreateContractRouteArgs.fromRoute(Object? value) {
    if (value is CreateContractRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return CreateContractRouteArgs(
      projectId: _parseId(map['projectId'] ?? map['project_id']),
      conversationId: _parseId(map['conversationId'] ?? map['conversation_id']),
      freelancerId: _parseId(map['freelancerId'] ?? map['user_id']),
      contractId: _parseId(map['contractId'] ?? map['contract_id']),
      contract: map['contract'] is ContractModel
          ? map['contract'] as ContractModel
          : null,
    );
  }

  static int? _parseId(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
