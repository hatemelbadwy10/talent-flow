import 'package:talent_flow/data/config/mapper.dart';

class PaymentModel extends SingleMapper{
  PaymentModel({
    required this.id,
    required this.image,
    required this.name,
    required this.items,
  });

  final int? id;
  final String? image;
  final String? name;
  final List<PaymentModel> items;

  factory PaymentModel.fromJson(Map<String, dynamic> json){
    return PaymentModel(
      id: json["id"],
      image: json["image"],
      name: json["name"],
      items: json["items"] == null ? [] : List<PaymentModel>.from(json["items"]!.map((x) => PaymentModel.fromJson(x))),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return PaymentModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}
