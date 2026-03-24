import 'package:talent_flow/data/config/mapper.dart';

class BankAccountModel implements Mapper {
  const BankAccountModel({
    this.id,
    this.name,
    this.number,
    this.bankId,
    this.bankName,
    this.ownerName,
  });

  final int? id;
  final String? name;
  final String? number;
  final int? bankId;
  final String? bankName;
  final String? ownerName;

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    final bankMap = json['bank'] is Map
        ? Map<String, dynamic>.from(json['bank'] as Map)
        : <String, dynamic>{};

    return BankAccountModel(
      id: _toInt(json['id']),
      name: _toText(
        json['name'] ?? json['title'] ?? json['account_name'],
      ),
      number: _toText(
        json['number'] ?? json['account_number'] ?? json['iban'],
      ),
      bankId: _toInt(
        json['bank_id'] ?? json['bankId'] ?? bankMap['id'],
      ),
      bankName: _toText(
        json['bank_name'] ??
            json['bankName'] ??
            bankMap['name'] ??
            bankMap['title'],
      ),
      ownerName: _toText(
        json['owner_name'] ?? json['account_owner_name'] ?? json['owner'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'bank_id': bankId,
      'bank_name': bankName,
      'owner_name': ownerName,
    };
  }
}

class BankOptionModel implements Mapper {
  const BankOptionModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory BankOptionModel.fromJson(Map<String, dynamic> json) {
    final parsedId = _toInt(json['id']) ?? _toInt(json['value']) ?? 0;
    return BankOptionModel(
      id: parsedId,
      name: _toText(json['name'] ?? json['title'] ?? json['label']) ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class BankAccountsResponseModel {
  const BankAccountsResponseModel({
    required this.items,
    this.message,
    this.status,
  });

  final List<BankAccountModel> items;
  final String? message;
  final bool? status;

  factory BankAccountsResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = _payload(json);
    final list = _extractList(payload);

    return BankAccountsResponseModel(
      items: list
          .whereType<Map>()
          .map((e) => BankAccountModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      message: _toText(json['message']),
      status: _toBool(json['status']),
    );
  }
}

class BankOptionsResponseModel {
  const BankOptionsResponseModel({
    required this.options,
    this.message,
    this.status,
  });

  final List<BankOptionModel> options;
  final String? message;
  final bool? status;

  factory BankOptionsResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = _payload(json);

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final data = map['data'] ?? map['items'] ?? map['banks'] ?? map;

      if (data is List) {
        return BankOptionsResponseModel(
          options: data
              .whereType<Map>()
              .map(
                  (e) => BankOptionModel.fromJson(Map<String, dynamic>.from(e)))
              .where((e) => e.id != 0 && e.name.isNotEmpty)
              .toList(),
          message: _toText(json['message']),
          status: _toBool(json['status']),
        );
      }

      if (data is Map) {
        final entries = Map<String, dynamic>.from(data).entries;
        return BankOptionsResponseModel(
          options: entries
              .map(
                (entry) => BankOptionModel(
                  id: _toInt(entry.key) ?? 0,
                  name: _toText(entry.value) ?? '',
                ),
              )
              .where((e) => e.id != 0 && e.name.isNotEmpty)
              .toList(),
          message: _toText(json['message']),
          status: _toBool(json['status']),
        );
      }
    }

    if (payload is List) {
      return BankOptionsResponseModel(
        options: payload
            .whereType<Map>()
            .map((e) => BankOptionModel.fromJson(Map<String, dynamic>.from(e)))
            .where((e) => e.id != 0 && e.name.isNotEmpty)
            .toList(),
        message: _toText(json['message']),
        status: _toBool(json['status']),
      );
    }

    return BankOptionsResponseModel(
      options: const [],
      message: _toText(json['message']),
      status: _toBool(json['status']),
    );
  }
}

class BankAccountMutationResponseModel {
  const BankAccountMutationResponseModel({
    this.item,
    this.message,
    this.status,
  });

  final BankAccountModel? item;
  final String? message;
  final bool? status;

  factory BankAccountMutationResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = _payload(json);

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final nested = map['item'] ?? map['bank_account'] ?? map['data'] ?? map;
      if (nested is Map) {
        return BankAccountMutationResponseModel(
          item: BankAccountModel.fromJson(Map<String, dynamic>.from(nested)),
          message: _toText(json['message']),
          status: _toBool(json['status']),
        );
      }
    }

    return BankAccountMutationResponseModel(
      message: _toText(json['message']),
      status: _toBool(json['status']),
    );
  }
}

dynamic _payload(Map<String, dynamic> json) {
  return json['payload'] ?? json['data'] ?? json;
}

List<dynamic> _extractList(dynamic payload) {
  if (payload is List) {
    return payload;
  }
  if (payload is Map) {
    final map = Map<String, dynamic>.from(payload);
    final nested =
        map['items'] ?? map['data'] ?? map['rows'] ?? map['accounts'];
    if (nested is List) {
      return nested;
    }
  }
  return const [];
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _toText(dynamic value) {
  final text = value?.toString();
  if (text == null || text.trim().isEmpty || text == 'null') {
    return null;
  }
  return text;
}

bool? _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final text = value?.toString().toLowerCase();
  if (text == 'true' || text == '1') {
    return true;
  }
  if (text == 'false' || text == '0') {
    return false;
  }
  return null;
}
