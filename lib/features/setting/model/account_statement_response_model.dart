import 'package:talent_flow/data/config/mapper.dart';

class AccountStatementItemModel implements Mapper {
  const AccountStatementItemModel({
    this.id,
    this.projectName,
    this.serviceProviderName,
    this.date,
    this.projectCost,
    this.commissionPaid,
  });

  final int? id;
  final String? projectName;
  final String? serviceProviderName;
  final String? date;
  final String? projectCost;
  final String? commissionPaid;

  factory AccountStatementItemModel.fromJson(Map<String, dynamic> json) {
    return AccountStatementItemModel(
      id: _toInt(json['id']),
      projectName: _toStringValue(
        json['project_name'] ?? json['project_title'] ?? json['title'],
      ),
      serviceProviderName: _toStringValue(
        json['service_provider_name'] ??
            json['provider_name'] ??
            (json['service_provider'] is Map
                ? json['service_provider']['name']
                : null),
      ),
      date: _toStringValue(json['date'] ?? json['created_at']),
      projectCost: _toStringValue(
        json['project_cost'] ?? json['cost'] ?? json['total_amount'],
      ),
      commissionPaid: _toStringValue(
        json['commission_paid'] ??
            json['commission_amount'] ??
            json['talent_flow_commission'],
      ),
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
            .map((e) => AccountStatementItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ))
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
              .map((e) => AccountStatementItemModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
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
      Map<String, dynamic> json) {
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
