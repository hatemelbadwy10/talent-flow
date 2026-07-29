import 'package:talent_flow/data/config/mapper.dart';

class FreelancersModel extends SingleMapper {
  FreelancersModel({
    required this.id,
    required this.name,
    required this.image,
    required this.jobTitle,
    required this.bio,
    required this.rating,
    required this.noOfReviews,
    required this.email,
    required this.country,
    required this.lang,
    required this.gender,
    required this.phone,
    required this.dateOfBirth,
    required this.googleId,
    required this.facebookId,
    required this.lastLoginAt,
    required this.loggedIn,
    required this.emailVerifiedAt,
    required this.phoneVerifiedAt,
    required this.isInFavorites,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;
  final String? bio;
  final double? rating;
  final int? noOfReviews;
  final String? email;
  final String? country;
  final String? lang;
  final String? gender;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? googleId;
  final String? facebookId;
  final DateTime? lastLoginAt;
  final bool? loggedIn;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final bool? isInFavorites;

  factory FreelancersModel.fromJson(Map<String, dynamic> json) {
    return FreelancersModel(
      id: _toInt(json["id"]),
      name: json["name"]?.toString(),
      image: json["image"]?.toString(),
      jobTitle: json["job_title"]?.toString(),
      bio: json["bio"]?.toString(),
      rating: _toDouble(json["rating"]),
      noOfReviews: _toInt(json["no_of_reviews"]),
      email: json["email"]?.toString(),
      country: json["country"]?.toString(),
      lang: json["lang"]?.toString(),
      gender: json["gender"]?.toString(),
      phone: json["phone"]?.toString(),
      dateOfBirth: _toDateTime(json["date_of_birth"]),
      googleId: json["google_id"]?.toString(),
      facebookId: json["facebook_id"]?.toString(),
      lastLoginAt: _toDateTime(json["last_login_at"]),
      loggedIn: _toBool(json["logged_in"]),
      emailVerifiedAt: _toDateTime(json["email_verified_at"]),
      phoneVerifiedAt: _toDateTime(json["phone_verified_at"]),
      isInFavorites: _toBool(json["is_in_favorites"] ?? json["is_fav"]),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return FreelancersModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'job_title': jobTitle,
        'bio': bio,
        'rating': rating,
        'no_of_reviews': noOfReviews,
        'email': email,
        'country': country,
        'lang': lang,
        'gender': gender,
        'phone': phone,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'google_id': googleId,
        'facebook_id': facebookId,
        'last_login_at': lastLoginAt?.toIso8601String(),
        'logged_in': loggedIn,
        'email_verified_at': emailVerifiedAt?.toIso8601String(),
        'phone_verified_at': phoneVerifiedAt?.toIso8601String(),
        'is_in_favorites': isInFavorites,
      };
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "");
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? "");
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase() ?? "";
  return normalized == "1" || normalized == "true" || normalized == "yes";
}

DateTime? _toDateTime(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? "");
}
