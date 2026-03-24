import 'package:talent_flow/data/config/mapper.dart';
import 'package:talent_flow/features/home/model/freelancers_model.dart';
import 'package:talent_flow/features/projects/model/my_projects_model.dart';

class FavouriteResponseModel implements Mapper {
  const FavouriteResponseModel({
    this.status,
    this.message,
    required this.payload,
  });

  final bool? status;
  final String? message;
  final FavouritePayloadModel payload;

  factory FavouriteResponseModel.fromJson(Map<String, dynamic> json) {
    final payloadMap = json['payload'] is Map
        ? Map<String, dynamic>.from(json['payload'] as Map)
        : <String, dynamic>{};

    return FavouriteResponseModel(
      status: _toBool(json['status']),
      message: _toText(json['message']),
      payload: FavouritePayloadModel.fromJson(payloadMap),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.toJson(),
    };
  }
}

class FavouritePayloadModel implements Mapper {
  const FavouritePayloadModel({
    required this.projects,
    required this.freelancers,
    required this.works,
  });

  final List<MyProjectsModel> projects;
  final List<FreelancersModel> freelancers;
  final List<FavouriteWorkModel> works;

  factory FavouritePayloadModel.fromJson(Map<String, dynamic> json) {
    final projectsRaw = json['projects'];
    final freelancersRaw = json['freelancers'];
    final worksRaw = json['works'];

    return FavouritePayloadModel(
      projects: projectsRaw is List
          ? projectsRaw
              .whereType<Map>()
              .map(
                  (e) => MyProjectsModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      freelancers: freelancersRaw is List
          ? freelancersRaw
              .whereType<Map>()
              .map((e) =>
                  FreelancersModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      works: worksRaw is List
          ? worksRaw
              .whereType<Map>()
              .map((e) =>
                  FavouriteWorkModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'projects': projects.map((e) => e.toJson()).toList(),
      'freelancers': freelancers
          .map(
            (e) => {
              'id': e.id,
              'name': e.name,
              'image': e.image,
              'job_title': e.jobTitle,
              'bio': e.bio,
              'rating': e.rating,
              'no_of_reviews': e.noOfReviews,
              'email': e.email,
              'country': e.country,
              'lang': e.lang,
              'gender': e.gender,
              'phone': e.phone,
              'date_of_birth': e.dateOfBirth?.toIso8601String(),
              'google_id': e.googleId,
              'facebook_id': e.facebookId,
              'last_login_at': e.lastLoginAt?.toIso8601String(),
              'logged_in': e.loggedIn,
              'email_verified_at': e.emailVerifiedAt?.toIso8601String(),
              'phone_verified_at': e.phoneVerifiedAt,
            },
          )
          .toList(),
      'works': works.map((e) => e.toJson()).toList(),
    };
  }
}

class FavouriteWorkModel implements Mapper {
  const FavouriteWorkModel({
    this.id,
    this.image,
    this.title,
    this.description,
    this.views,
    this.likes,
    this.status,
  });

  final int? id;
  final String? image;
  final String? title;
  final String? description;
  final int? views;
  final int? likes;
  final String? status;

  factory FavouriteWorkModel.fromJson(Map<String, dynamic> json) {
    return FavouriteWorkModel(
      id: _toInt(json['id']),
      image: _toText(json['image']),
      title: _toText(json['title']),
      description: _toText(json['description']),
      views: _toInt(json['views']),
      likes: _toInt(json['likes']),
      status: _toText(json['status']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'description': description,
      'views': views,
      'likes': likes,
      'status': status,
    };
  }
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _toText(dynamic value) {
  final text = value?.toString();
  if (text == null || text.trim().isEmpty || text == 'null') {
    return null;
  }
  return text;
}

bool? _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final text = value?.toString().toLowerCase();
  if (text == 'true' || text == '1') {
    return true;
  }
  if (text == 'false' || text == '0') {
    return false;
  }
  return null;
}
