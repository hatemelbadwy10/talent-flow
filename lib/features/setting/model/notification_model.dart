import 'package:talent_flow/data/config/mapper.dart';

class NotificationModel extends SingleMapper {
  NotificationModel({
    required this.id,
    required this.date,
    required this.title,
    required this.message,
    required this.data,
    required this.readStatus,
  });

  final int? id;
  final DateTime? date;
  final String? title;
  final String? message;
  final Data? data;
  final int? readStatus;

  factory NotificationModel.fromJson(Map<String, dynamic> json){
    return NotificationModel(
      id: json["id"],
      date: DateTime.tryParse(json["date"] ?? ""),
      title: json["title"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
      readStatus: json["read_status"],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
   return NotificationModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}

class Data {
  Data({
    required this.type,
    required this.extra,
    required this.amount,
    required this.freelancerId,
  });

  final String? type;
  final String? extra;
  final String? amount;
  final int? freelancerId;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      type: json["type"],
      extra: json["extra"],
      amount: json["amount"],
      freelancerId: json["freelancer_id"],
    );
  }

}
