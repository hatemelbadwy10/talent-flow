import 'package:talent_flow/data/config/mapper.dart';

class UserModel extends SingleMapper {
  int? id;
  String? name;
  String? profileImage;
  String? phone;
  String? email;


  UserModel({
    this.id,
    this.name,
    this.profileImage,
    this.phone,
    this.email,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profileImage = json['profile_image'];
    phone = json['phone_number'];
    email = json['email'];

  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profile_image'] = profileImage;
    data['phone_number'] = phone;
    data['email'] = email;


    return data;
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }
}
