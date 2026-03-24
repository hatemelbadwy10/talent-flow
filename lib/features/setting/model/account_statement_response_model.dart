import 'package:talent_flow/data/config/mapper.dart';

class AccountStatementItemModel implements Mapper {
  const AccountStatementItemModel({
    this.id,
    this.projectName,
    this.serviceProviderName,
    this.date,
    this.projectCost,
    this.commissionPaid,
    this.description,
    this.files = const [],
    this.views,
    this.since,
    this.status,
    this.duration,
    this.budget,
    this.owner,
    this.proposals,
  });

  final int? id;
  final String? projectName;
  final String? serviceProviderName;
  final String? date;
  final String? projectCost;
  final String? commissionPaid;
  final String? description;
  final List<String> files;
  final int? views;
  final String? since;
  final String? status;
  final int? duration;
  final String? budget;
  final AccountStatementOwnerModel? owner;
  final AccountStatementProposalsModel? proposals;

  factory AccountStatementItemModel.fromJson(Map<String, dynamic> json) {
    final ownerMap = _asMap(json['owner']);
    return AccountStatementItemModel(
      id: _toInt(json['id']),
      projectName: _toStringValue(
        json['project_name'] ?? json['project_title'] ?? json['title'],
      ),
      serviceProviderName: _toStringValue(
        json['service_provider_name'] ??
            json['provider_name'] ??
            json['freelancer'] ??
            ownerMap?['name'] ??
            (json['service_provider'] is Map
                ? json['service_provider']['name']
                : null),
      ),
      date: _toStringValue(json['date'] ?? json['created_at']),
      projectCost: _toStringValue(
        json['project_cost'] ??
            json['cost'] ??
            json['total_amount'] ??
            json['budget'],
      ),
      commissionPaid: _toStringValue(
        json['commission_paid'] ??
            json['commission_amount'] ??
            json['talent_flow_commission'],
      ),
      description: _toStringValue(json['description']),
      files: _extractFiles(json['files'] ?? json['attachments']),
      views: _toInt(json['views']),
      since: _toStringValue(json['since']),
      status: _toStringValue(json['status']),
      duration: _toInt(json['duration']),
      budget: _toStringValue(json['budget']),
      owner: ownerMap == null
          ? null
          : AccountStatementOwnerModel.fromJson(ownerMap),
      proposals: AccountStatementProposalsModel.fromDynamic(json['proposals']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_name': projectName,
      'service_provider_name': serviceProviderName,
      'date': date,
      'project_cost': projectCost,
      'commission_paid': commissionPaid,
      'description': description,
      'files': files,
      'views': views,
      'since': since,
      'status': status,
      'duration': duration,
      'budget': budget,
      'owner': owner?.toJson(),
      'proposals': proposals?.toJson(),
    };
  }
}

class AccountStatementOwnerModel implements Mapper {
  const AccountStatementOwnerModel({
    this.id,
    this.name,
    this.image,
    this.jobTitle,
    this.signupDate,
    this.employmentRate,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;
  final String? signupDate;
  final String? employmentRate;

  factory AccountStatementOwnerModel.fromJson(Map<String, dynamic> json) {
    return AccountStatementOwnerModel(
      id: _toInt(json['id']),
      name: _toStringValue(json['name']),
      image: _toStringValue(json['image']),
      jobTitle: _toStringValue(json['job_title']),
      signupDate: _toStringValue(json['signup_date']),
      employmentRate: _toStringValue(json['employment_rate']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'job_title': jobTitle,
      'signup_date': signupDate,
      'employment_rate': employmentRate,
    };
  }
}

class AccountStatementProposalsModel implements Mapper {
  const AccountStatementProposalsModel({
    this.count,
    this.items = const [],
  });

  final int? count;
  final List<dynamic> items;

  factory AccountStatementProposalsModel.fromDynamic(dynamic value) {
    if (value is Map<String, dynamic>) {
      return AccountStatementProposalsModel(
        count: _toInt(value['count']) ??
            (value['items'] is List ? (value['items'] as List).length : null),
        items: value['items'] is List ? List<dynamic>.from(value['items']) : [],
      );
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return AccountStatementProposalsModel(
        count: _toInt(map['count']) ??
            (map['items'] is List ? (map['items'] as List).length : null),
        items: map['items'] is List ? List<dynamic>.from(map['items']) : [],
      );
    }

    if (value is List) {
      return AccountStatementProposalsModel(
        count: value.length,
        items: List<dynamic>.from(value),
      );
    }

    return const AccountStatementProposalsModel();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'items': items,
    };
  }
}

class AccountStatementIndexResponseModel {
  const AccountStatementIndexResponseModel({
    required this.items,
    this.currentPage,
    this.lastPage,
    this.total,
    this.perPage,
    this.message,
  });

  final List<AccountStatementItemModel> items;
  final int? currentPage;
  final int? lastPage;
  final int? total;
  final int? perPage;
  final String? message;

  factory AccountStatementIndexResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final payload = _payload(json);
    if (payload is List) {
      return AccountStatementIndexResponseModel(
        items: payload
            .whereType<Map>()
            .map(
              (e) => AccountStatementItemModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList(),
        message: _toStringValue(json['message']),
      );
    }

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final dynamic listRaw =
          map['items'] ?? map['data'] ?? map['rows'] ?? map['statements'];
      final list = listRaw is List
          ? listRaw
              .whereType<Map>()
              .map(
                (e) => AccountStatementItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : <AccountStatementItemModel>[];

      return AccountStatementIndexResponseModel(
        items: list,
        currentPage: _toInt(map['current_page'] ?? map['page']),
        lastPage: _toInt(map['last_page']),
        total: _toInt(map['total']),
        perPage: _toInt(map['per_page']),
        message: _toStringValue(json['message']),
      );
    }

    return const AccountStatementIndexResponseModel(items: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'current_page': currentPage,
      'last_page': lastPage,
      'total': total,
      'per_page': perPage,
      'message': message,
    };
  }
}

class AccountStatementShowResponseModel {
  const AccountStatementShowResponseModel({
    this.item,
    this.message,
  });

  final AccountStatementItemModel? item;
  final String? message;

  factory AccountStatementShowResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final payload = _payload(json);
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final nested =
          map['item'] ?? map['statement'] ?? map['data'] ?? map['details'];
      final source = nested is Map ? nested : map;
      return AccountStatementShowResponseModel(
        item: AccountStatementItemModel.fromJson(
          Map<String, dynamic>.from(source),
        ),
        message: _toStringValue(json['message']),
      );
    }

    if (payload is List && payload.isNotEmpty && payload.first is Map) {
      return AccountStatementShowResponseModel(
        item: AccountStatementItemModel.fromJson(
          Map<String, dynamic>.from(payload.first as Map),
        ),
        message: _toStringValue(json['message']),
      );
    }

    return const AccountStatementShowResponseModel();
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item?.toJson(),
      'message': message,
    };
  }
}

dynamic _payload(Map<String, dynamic> json) {
  return json['payload'] ?? json['data'] ?? json;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _toStringValue(dynamic value) {
  final text = value?.toString();
  if (text == null || text.trim().isEmpty || text == 'null') {
    return null;
  }
  return text;
}

List<String> _extractFiles(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) {
        if (item is String) return item.trim();
        if (item is Map<String, dynamic>) {
          return _toStringValue(item['url']) ??
              _toStringValue(item['file']) ??
              _toStringValue(item['path']) ??
              '';
        }
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          return _toStringValue(map['url']) ??
              _toStringValue(map['file']) ??
              _toStringValue(map['path']) ??
              '';
        }
        return item.toString().trim();
      })
      .where((item) => item.isNotEmpty)
      .toList();
}
