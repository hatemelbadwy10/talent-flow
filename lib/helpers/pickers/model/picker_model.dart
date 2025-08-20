import 'dart:io';

import 'package:talent_flow/data/config/mapper.dart';

class PickerModel extends SingleMapper {
  File? file;
  String? url;

  PickerModel({
    this.file,
    this.url,
  });

  PickerModel.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file'] = file;
    data['url'] = url;
    return data;
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return PickerModel.fromJson(json);
  }
}
