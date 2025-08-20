import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talent_flow/main_models/custom_field_model.dart';

class AttachmentModel {
  int? id;
  String? image;
  String? name;
  CustomFieldModel? type;
  File? file;

  AttachmentModel({
    this.id,
    this.image,
    this.name,
    this.type,
    this.file,
  });

  AttachmentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['url'];
    name = json['name'];
    type = json['file_type'] != null
        ? CustomFieldModel.fromJson(json['file_type'])
        : null;
  }

  Map<String, dynamic> toQualification() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file'] = MultipartFile.fromFileSync(file?.path ?? "");
    data['file_type_id'] = type?.id;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = image;
    data['file_type'] = type?.toJson();
    return data;
  }

  AttachmentModel copyWith({File? file, String? name, CustomFieldModel? type}) {
    this.file = file ?? this.file;
    this.name = name ?? this.name;
    this.type = type ?? this.type;
    return this;
  }

  bool isBodyValid() {
    log("==>isBody ${toQualification()}");

    for (var entry in toQualification().entries) {
      final value = entry.value;
      if (value == null || (value is String && value.trim().isEmpty)) {
        log("==>isBodyValid${false}");
        return false;
      }
    }
    log("==>isBodyValid${true}");
    return true;
  }
}
