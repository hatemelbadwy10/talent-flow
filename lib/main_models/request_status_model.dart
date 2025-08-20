import '../data/config/mapper.dart';

class RequestStatusModel extends SingleMapper {
  String? message;
  int? statusCode;
  List<StatusModel>? data;

  RequestStatusModel({
    this.message,
    this.statusCode,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        "message": message,
        "status_code": statusCode,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
      };

  RequestStatusModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['status_code'];
    if (json['data'] != null) {
      data = [StatusModel(key: "all", value: "All", color: "#18A5F1")];
      json['data'].forEach((v) {
        data!.add(StatusModel.fromJson(v));
      });
    }
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return RequestStatusModel.fromJson(json);
  }
}

class StatusModel {
  String? key;
  String? value;
  String? icon;
  String? color;

  StatusModel({this.key, this.value, this.icon, this.color});

  StatusModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
    icon = json['icon'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    data['icon'] = icon;
    data['color'] = color;
    return data;
  }
}
