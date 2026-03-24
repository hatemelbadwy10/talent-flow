import 'package:talent_flow/data/config/mapper.dart';

class DashboardResponseModel implements Mapper {
  const DashboardResponseModel({
    this.balances,
    this.counters,
    required this.statuses,
    required this.recentProjects,
    required this.rawPayload,
  });

  final DashboardBalancesModel? balances;
  final DashboardCountersModel? counters;
  final List<DashboardStatusModel> statuses;
  final List<DashboardRecentProjectModel> recentProjects;
  final Map<String, dynamic> rawPayload;

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    final payloadDynamic = _extractPayload(json);
    final payload = payloadDynamic is Map
        ? Map<String, dynamic>.from(payloadDynamic)
        : <String, dynamic>{};

    final balancesSource = payload['balances'] is Map
        ? Map<String, dynamic>.from(payload['balances'])
        : payload['balance'] is Map
            ? Map<String, dynamic>.from(payload['balance'])
            : payload['wallet'] is Map
                ? Map<String, dynamic>.from(payload['wallet'])
                : payload;

    final countersSource = payload['counts'] is Map
        ? Map<String, dynamic>.from(payload['counts'])
        : payload['statistics'] is Map
            ? Map<String, dynamic>.from(payload['statistics'])
            : payload;

    final messagesSource = payload['messages'] is Map
        ? Map<String, dynamic>.from(payload['messages'])
        : <String, dynamic>{};
    final contractsSource = payload['contracts'] is Map
        ? Map<String, dynamic>.from(payload['contracts'])
        : <String, dynamic>{};
    final worksSource = payload['works'] is Map
        ? Map<String, dynamic>.from(payload['works'])
        : <String, dynamic>{};
    final projectsSource = payload['projects'] is Map
        ? Map<String, dynamic>.from(payload['projects'])
        : <String, dynamic>{};

    final statusesRaw = payload['statuses'] ??
        payload['project_statuses'] ??
        payload['projects_statuses'] ??
        projectsSource['statuses'];

    final statuses = statusesRaw is List
        ? statusesRaw
            .whereType<Map>()
            .map(
              (e) =>
                  DashboardStatusModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList()
        : <DashboardStatusModel>[];

    final recentProjectsRaw =
        payload['recent_projects'] ?? payload['recentProjects'];
    final recentProjects = recentProjectsRaw is List
        ? recentProjectsRaw
            .whereType<Map>()
            .map(
              (e) => DashboardRecentProjectModel.fromJson(
                  Map<String, dynamic>.from(e)),
            )
            .toList()
        : <DashboardRecentProjectModel>[];

    // WARNING: Unverified response mapping - Postman request has no examples.
    return DashboardResponseModel(
      balances: DashboardBalancesModel.fromJson(balancesSource),
      counters: DashboardCountersModel.fromJson({
        ...countersSource,
        'my_projects': projectsSource['total'] ??
            projectsSource['count'] ??
            worksSource['total'] ??
            worksSource['count'] ??
            payload['projects_count'] ??
            payload['works_count'],
        'new_messages': messagesSource['unread'] ??
            messagesSource['new'] ??
            messagesSource['unread_count'],
        'incoming_messages': messagesSource['inbox'] ??
            messagesSource['incoming'] ??
            messagesSource['inbox_count'],
        'contracts': contractsSource['total'] ??
            contractsSource['count'] ??
            payload['contracts_count'],
      }),
      statuses: statuses,
      recentProjects: recentProjects,
      rawPayload: payload,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'balances': balances?.toJson(),
      'counters': counters?.toJson(),
      'statuses': statuses.map((e) => e.toJson()).toList(),
      'recent_projects': recentProjects.map((e) => e.toJson()).toList(),
      'raw_payload': rawPayload,
    };
  }
}

class DashboardBalancesModel implements Mapper {
  const DashboardBalancesModel({
    this.totalBalance,
    this.withdrawableBalance,
    this.pendingBalance,
    this.outgoingBalance,
  });

  final String? totalBalance;
  final String? withdrawableBalance;
  final String? pendingBalance;
  final String? outgoingBalance;

  factory DashboardBalancesModel.fromJson(Map<String, dynamic> json) {
    return DashboardBalancesModel(
      totalBalance: _toText(
        json['total_balance'] ?? json['balance_total'] ?? json['total'],
      ),
      withdrawableBalance: _toText(
        json['withdrawable_balance'] ??
            json['available_balance'] ??
            json['available'],
      ),
      pendingBalance: _toText(
        json['pending_balance'] ?? json['balance_pending'] ?? json['pending'],
      ),
      outgoingBalance: _toText(
        json['outgoing_balance'] ?? json['spent_balance'] ?? json['outgoing'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'total_balance': totalBalance,
      'withdrawable_balance': withdrawableBalance,
      'pending_balance': pendingBalance,
      'outgoing_balance': outgoingBalance,
    };
  }
}

class DashboardCountersModel implements Mapper {
  const DashboardCountersModel({
    this.myProjects,
    this.newMessages,
    this.incomingMessages,
    this.contracts,
  });

  final int? myProjects;
  final int? newMessages;
  final int? incomingMessages;
  final int? contracts;

  factory DashboardCountersModel.fromJson(Map<String, dynamic> json) {
    return DashboardCountersModel(
      myProjects: _toInt(
        json['my_projects'] ?? json['projects_count'] ?? json['projects'],
      ),
      newMessages: _toInt(
        json['new_messages'] ??
            json['new_messages_count'] ??
            json['messages_new'],
      ),
      incomingMessages: _toInt(
        json['incoming_messages'] ??
            json['inbox_messages'] ??
            json['incoming_messages_count'],
      ),
      contracts: _toInt(
        json['contracts'] ?? json['contracts_count'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'my_projects': myProjects,
      'new_messages': newMessages,
      'incoming_messages': incomingMessages,
      'contracts': contracts,
    };
  }
}

class DashboardStatusModel implements Mapper {
  const DashboardStatusModel({
    this.name,
    this.count,
    this.percentage,
  });

  final String? name;
  final int? count;
  final double? percentage;

  factory DashboardStatusModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatusModel(
      name: _toText(
        json['name'] ?? json['label'] ?? json['title'] ?? json['status'],
      ),
      count: _toInt(json['count'] ?? json['total']),
      percentage: _toDouble(json['percentage'] ?? json['percent']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'percentage': percentage,
    };
  }
}

class DashboardRecentProjectModel implements Mapper {
  const DashboardRecentProjectModel({
    this.id,
    this.title,
    this.createdAt,
    this.ownerName,
    this.proposalsCount,
  });

  final int? id;
  final String? title;
  final String? createdAt;
  final String? ownerName;
  final int? proposalsCount;

  factory DashboardRecentProjectModel.fromJson(Map<String, dynamic> json) {
    return DashboardRecentProjectModel(
      id: _toInt(json['id']),
      title: _toText(json['title']),
      createdAt: _toText(json['created_at']),
      ownerName: _toText(json['owner_name']),
      proposalsCount: _toInt(json['proposals_count']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt,
      'owner_name': ownerName,
      'proposals_count': proposalsCount,
    };
  }
}

dynamic _extractPayload(Map<String, dynamic> json) {
  return json['payload'] ?? json['data'] ?? json;
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

String? _toText(dynamic value) {
  final text = value?.toString();
  if (text == null || text.trim().isEmpty || text == 'null') {
    return null;
  }
  return text;
}
