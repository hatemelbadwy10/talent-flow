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
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;
  final String? bio;
  final int? rating;
  final int? noOfReviews;
  final String? email;
  final String? country;
  final String? lang;
  final String? gender;
  final String? phone;
  final DateTime? dateOfBirth;
  final dynamic googleId;
  final dynamic facebookId;
  final DateTime? lastLoginAt;
  final bool? loggedIn;
  final DateTime? emailVerifiedAt;
  final dynamic phoneVerifiedAt;

  factory FreelancersModel.fromJson(Map<String, dynamic> json){
    return FreelancersModel(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      jobTitle: json["job_title"],
      bio: json["bio"],
      rating: json["rating"],
      noOfReviews: json["no_of_reviews"],
      email: json["email"],
      country: json["country"],
      lang: json["lang"],
      gender: json["gender"],
      phone: json["phone"],
      dateOfBirth: DateTime.tryParse(json["date_of_birth"] ?? ""),
      googleId: json["google_id"],
      facebookId: json["facebook_id"],
      lastLoginAt: DateTime.tryParse(json["last_login_at"] ?? ""),
      loggedIn: json["logged_in"],
      emailVerifiedAt: DateTime.tryParse(json["email_verified_at"] ?? ""),
      phoneVerifiedAt: json["phone_verified_at"],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
   return FreelancersModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}
