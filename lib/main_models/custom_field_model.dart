import '../../../data/config/mapper.dart';
import 'meta.dart';

class CustomFieldsModel extends SingleMapper {
  String? message;
  int? statusCode;
  List<CustomFieldModel>? data;

  Meta? meta;

  CustomFieldsModel({
    this.message,
    this.statusCode,
    this.data,
    this.meta,
  });

  @override
  Map<String, dynamic> toJson() => {
        "message": message,
        "status_code": statusCode,
        "meta": meta?.toJson(),
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
      };

  CustomFieldsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['status_code'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;

    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(CustomFieldModel.fromJson(v));
      });
    }
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return CustomFieldsModel.fromJson(json);
  }
}

class CustomFieldModel extends SingleMapper {
  int? id;
  String? name;
  String? description;
  String? image;
  String? code;
  String? type;
  bool? isSelect;

  CustomFieldModel({
    this.id,
    this.name,
    this.description,
    this.image,
    this.code,
    this.type,
    this.isSelect,
  });

  CustomFieldModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"] ?? json["title"] ?? "";
    description = json["desc"];
    code = json["code"];
    type = json["type"] != null && json["type"]["key"] != null
        ? json["type"]["key"]?.toString()
        : null;
    image = json["image"];
    isSelect = false;
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "desc": description,
        "image": image,
        "code": code,
        "type": {"key": type},
        "is_select": isSelect,
      };

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return CustomFieldModel.fromJson(json);
  }
}
