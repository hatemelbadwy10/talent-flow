final class FreelancersRouteArgs {
  const FreelancersRouteArgs({this.categoryId});

  final int? categoryId;

  factory FreelancersRouteArgs.fromRoute(Object? value) {
    if (value is FreelancersRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return FreelancersRouteArgs(categoryId: _toInt(map['categoryId']));
  }
}

final class EntrepreneurProfileArgs {
  const EntrepreneurProfileArgs({
    this.entrepreneurId,
    this.useCurrentProfile = false,
  });

  final int? entrepreneurId;
  final bool useCurrentProfile;

  factory EntrepreneurProfileArgs.fromRoute(Object? value) {
    if (value is EntrepreneurProfileArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return EntrepreneurProfileArgs(
      entrepreneurId: _toInt(map['entrepreneurId']),
      useCurrentProfile: map['useCurrentProfile'] == true,
    );
  }
}

final class FreelancerProfileArgs {
  const FreelancerProfileArgs({required this.freelancerId});

  final int freelancerId;

  factory FreelancerProfileArgs.fromRoute(Object? value) {
    if (value is FreelancerProfileArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return FreelancerProfileArgs(
      freelancerId: _toInt(map['freelancerId']) ?? 0,
    );
  }
}

final class ChatRouteArgs {
  const ChatRouteArgs({
    this.conversationId,
    this.freelancerId,
    this.projectId,
    this.contractId,
    this.hasContract = false,
    this.freelancerName,
    this.freelancerJobTitle,
  });

  final int? conversationId;
  final int? freelancerId;
  final int? projectId;
  final int? contractId;
  final bool hasContract;
  final String? freelancerName;
  final String? freelancerJobTitle;

  factory ChatRouteArgs.fromRoute(Object? value) {
    if (value is ChatRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return ChatRouteArgs(
      conversationId: _toInt(map['conversationId']),
      freelancerId: _toInt(map['freelancerId']),
      projectId: _toInt(map['projectId'] ?? map['project_id']),
      contractId: _toInt(map['contractId'] ?? map['contract_id']),
      hasContract: map['hasContract'] == true,
      freelancerName: _optionalString(map['freelancerName']),
      freelancerJobTitle: _optionalString(map['freelancerJobTitle']),
    );
  }

  Map<String, Object?> toLogMap() => {
        'conversationId': conversationId,
        'freelancerId': freelancerId,
        'projectId': projectId,
        'contractId': contractId,
        'hasContract': hasContract,
        'freelancerName': freelancerName,
        'freelancerJobTitle': freelancerJobTitle,
      };
}

int? _toInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _optionalString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
