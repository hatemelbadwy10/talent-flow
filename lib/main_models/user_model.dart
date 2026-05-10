import 'package:talent_flow/data/config/mapper.dart';

class UserModel extends SingleMapper {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  String? jobTitle;
  String? profileImage;
  String? phone;
  String? email;
  String? userType;
  String? bio;
  String? specialization;
  String? identityVerifyStatus;
  bool? addedWorks;
  bool? identityAuthenticated;
  bool? bankAccountAdded;
  int? unreadNotificationsCount;
  int? unreadMessagesCount;

  UserModel({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.jobTitle,
    this.profileImage,
    this.phone,
    this.email,
    this.userType,
    this.bio,
    this.specialization,
    this.identityVerifyStatus,
    this.addedWorks,
    this.identityAuthenticated,
    this.bankAccountAdded,
    this.unreadNotificationsCount,
    this.unreadMessagesCount,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    final firstName = json['first_name']?.toString().trim();
    final lastName = json['last_name']?.toString().trim();
    this.firstName = firstName;
    this.lastName = lastName;
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
    userType = json['user_type']?.toString();
    bio = json['bio']?.toString();
    specialization = json['specialization']?.toString();
    identityVerifyStatus = json['identity_verify_status']?.toString();
    addedWorks = _toBool(json['added_works']);
    identityAuthenticated = _toBool(json['identity_authenticated']);
    bankAccountAdded =
        _toBool(json['bank_account_added'] ?? json['has_bank_account']);
    unreadNotificationsCount =
        _toInt(json['unread_notifications_count']) ?? 0;
    unreadMessagesCount = _toInt(json['unread_messages_count']) ?? 0;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['job_title'] = jobTitle;
    data['profile_image'] = profileImage;
    data['image'] = profileImage;
    data['phone_number'] = phone;
    data['phone'] = phone;
    data['email'] = email;
    data['user_type'] = userType;
    data['bio'] = bio;
    data['specialization'] = specialization;
    data['identity_verify_status'] = identityVerifyStatus;
    data['added_works'] = addedWorks;
    data['identity_authenticated'] = identityAuthenticated;
    data['bank_account_added'] = bankAccountAdded;
    data['has_bank_account'] = bankAccountAdded;
    data['unread_notifications_count'] = unreadNotificationsCount;
    data['unread_messages_count'] = unreadMessagesCount;

    return data;
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }
}

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
