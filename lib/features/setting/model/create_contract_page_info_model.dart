class CreateContractPageInfoModel {
  const CreateContractPageInfoModel({
    this.projectId,
    this.currency,
    this.projectTitle,
    this.projectOwner,
    this.currentBudget,
    this.currentDuration,
    this.durationValue,
    this.talentPercentageOfContracts,
    this.terminationConditions,
    this.conflictPolicy,
    this.contractName,
    this.contractDate,
    this.agreedCost,
    this.contractTerms,
    this.additionalNotes,
    this.filesDescription,
  });

  final int? projectId;
  final String? currency;
  final String? projectTitle;
  final String? projectOwner;
  final String? currentBudget;
  final String? currentDuration;
  final String? durationValue;
  final String? talentPercentageOfContracts;
  final String? terminationConditions;
  final String? conflictPolicy;
  final String? contractName;
  final String? contractDate;
  final String? agreedCost;
  final String? contractTerms;
  final String? additionalNotes;
  final String? filesDescription;

  factory CreateContractPageInfoModel.fromJson(Map<String, dynamic> json) {
    final project = _asMap(
          json['project'] ?? json['project_data'] ?? json['project_info'],
        ) ??
        const <String, dynamic>{};
    final contract = _asMap(
          json['contract'] ?? json['contract_data'] ?? json['contract_info'],
        ) ??
        const <String, dynamic>{};
    final owner = _asMap(
          json['owner'] ??
              json['client'] ??
              json['project_owner'] ??
              project['owner'] ??
              project['client'],
        ) ??
        const <String, dynamic>{};

    return CreateContractPageInfoModel(
      projectId: _firstInt([
        json['project_id'],
        project['id'],
      ]),
      currency: _firstString([
        json['currency'],
        contract['currency'],
        project['currency'],
      ]),
      projectTitle: _firstString([
        json['project_title'],
        project['title'],
        project['name'],
        json['title'],
      ]),
      projectOwner: _firstString([
        json['project_owner'],
        json['project_owner_name'],
        json['owner_name'],
        owner['name'],
      ]),
      currentBudget: _composeBudget(
        _firstValue([
          json['project_budget'],
          json['current_budget'],
          project['budget'],
          json['budget'],
        ]),
        _firstString([
          json['currency'],
          project['currency'],
        ]),
      ),
      currentDuration: _composeDuration(
        _firstValue([
          json['project_duration'],
          json['current_duration'],
          project['duration'],
          json['duration'],
        ]),
        _firstString([
          json['duration_unit'],
          json['duration_type'],
          project['duration_unit'],
          project['duration_type'],
        ]),
      ),
      durationValue: _extractNumberString(
        _firstValue([
          json['project_duration'],
          json['current_duration'],
          project['duration'],
          json['duration'],
        ]),
      ),
      talentPercentageOfContracts: _firstString([
        json['talent_percentage_of_contracts'],
      ]),
      terminationConditions: _firstString([
        json['termination_conditions'],
      ]),
      conflictPolicy: _firstString([
        json['conflict_policy'],
      ]),
      contractName: _firstString([
        contract['name'],
        contract['contract_name'],
        json['contract_name'],
      ]),
      contractDate: _firstString([
        contract['date'],
        contract['contract_date'],
        json['date'],
        json['contract_date'],
      ]),
      agreedCost: _composeBudget(
        _firstValue([
          contract['agreed_cost'],
          contract['cost'],
          json['agreed_cost'],
          json['cost'],
        ]),
        _firstString([
          contract['currency'],
          json['currency'],
          project['currency'],
        ]),
      ),
      contractTerms: _firstString([
        contract['terms'],
        contract['contract_terms'],
        json['contract_terms'],
        json['terms'],
      ]),
      additionalNotes: _firstString([
        contract['notes'],
        contract['additional_notes'],
        json['additional_notes'],
        json['notes'],
      ]),
      filesDescription: _firstString([
        contract['files_description'],
        json['files_description'],
      ]),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

dynamic _firstValue(List<dynamic> values) {
  for (final value in values) {
    if (value == null) {
      continue;
    }
    if (value is String && value.trim().isEmpty) {
      continue;
    }
    return value;
  }
  return null;
}

String? _firstString(List<dynamic> values) {
  final value = _firstValue(values);
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _firstInt(List<dynamic> values) {
  for (final value in values) {
    if (value is int) {
      return value;
    }
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

String? _composeBudget(dynamic amount, String? currency) {
  final amountText = amount?.toString().trim();
  final currencyText = currency?.trim();
  if ((amountText ?? '').isEmpty) {
    return null;
  }
  if ((currencyText ?? '').isEmpty) {
    return amountText;
  }
  return '$amountText $currencyText';
}

String? _composeDuration(dynamic duration, String? unit) {
  final durationText = duration?.toString().trim();
  final unitText = unit?.trim();
  if ((durationText ?? '').isEmpty) {
    return null;
  }
  if ((unitText ?? '').isEmpty) {
    return durationText;
  }
  return '$durationText $unitText';
}

String? _extractNumberString(dynamic value) {
  final text = value?.toString() ?? '';
  final match = RegExp(r'\d+').firstMatch(text);
  return match?.group(0);
}
