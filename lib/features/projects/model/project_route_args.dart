final class ProjectListRouteArgs {
  const ProjectListRouteArgs({
    this.categoryId,
    this.categoryName,
  });

  final int? categoryId;
  final String? categoryName;

  factory ProjectListRouteArgs.fromRoute(Object? value) {
    if (value is ProjectListRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return ProjectListRouteArgs(
      categoryId: _toInt(map['categoryId']),
      categoryName: _optionalString(map['categoryName']),
    );
  }
}

final class ProjectDetailsRouteArgs {
  const ProjectDetailsRouteArgs({required this.projectId});

  final int projectId;

  factory ProjectDetailsRouteArgs.fromRoute(Object? value) {
    if (value is ProjectDetailsRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return ProjectDetailsRouteArgs(
      projectId: _toInt(map['id'] ?? map['projectId']) ?? 0,
    );
  }
}

final class OfferRouteArgs {
  const OfferRouteArgs({
    required this.projectId,
    this.proposalId,
    this.initialDescription,
  });

  final int projectId;
  final int? proposalId;
  final String? initialDescription;

  factory OfferRouteArgs.fromRoute(Object? value) {
    if (value is OfferRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return OfferRouteArgs(
      projectId: _toInt(map['id'] ?? map['projectId']) ?? 0,
      proposalId: _toInt(map['proposalId']),
      initialDescription: _optionalString(map['initialDescription']),
    );
  }
}

int? _toInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _optionalString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
