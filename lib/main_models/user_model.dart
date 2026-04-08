import 'package:talent_flow/data/config/mapper.dart';

class UserModel extends SingleMapper {
  int? id;
  String? name;
  String? jobTitle;
  String? profileImage;
  String? phone;
  String? email;
  String? identityVerifyStatus;

  UserModel({
    this.id,
    this.name,
    this.jobTitle,
    this.profileImage,
    this.phone,
    this.email,
    this.identityVerifyStatus,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    final firstName = json['first_name']?.toString().trim();
    final lastName = json['last_name']?.toString().trim();
    final combinedName = [firstName, lastName]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(' ');
    name = (json['name']?.toString().trim().isNotEmpty ?? false)
        ? json['name'].toString().trim()
        : (combinedName.isNotEmpty ? combinedName : null);
    jobTitle = json['job_title']?.toString();
    profileImage =
        json['profile_image']?.toString() ?? json['image']?.toString();
    phone = json['phone_number']?.toString() ?? json['phone']?.toString();
    email = json['email'];
    identityVerifyStatus = json['identity_verify_status']?.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['job_title'] = jobTitle;
    data['profile_image'] = profileImage;
    data['phone_number'] = phone;
    data['email'] = email;
    data['identity_verify_status'] = identityVerifyStatus;

    return data;
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }
}
