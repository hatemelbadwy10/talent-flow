import 'package:talent_flow/data/config/mapper.dart';

class ConfigModel extends SingleMapper {
  String? message;
  Data? data;
  int? statusCode;

  ConfigModel({this.statusCode, this.message, this.data});

  ConfigModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status_code'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return ConfigModel.fromJson(json);
  }
}

class Data {
  int? id;
  String? video;
  String? logo;

  Data({
    this.video,
    this.logo,
  });

  Data.fromJson(Map<String, dynamic> json) {
    logo = json['name'];
    video = json['terms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['terms'] = video;
    data['name'] = logo;
    return data;
  }
}
