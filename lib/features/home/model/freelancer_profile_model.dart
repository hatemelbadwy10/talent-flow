import 'package:talent_flow/data/config/mapper.dart';

class FreelancerProfileModel extends SingleMapper {
  FreelancerProfileModel({
    required this.id,
    required this.name,
    required this.image,
    required this.country,
    required this.specialization,
    required this.jobTitle,
    required this.addedWorks,
    required this.identityAuthenticated,
    required this.bankAccountAdded,
    required this.bio,
    required this.skills,
    required this.statistics,
    required this.reviews,
    required this.works,
  });

  final int? id;
  final String? name;
  final String? image;
  final dynamic country;
  final String? specialization;
  final String? jobTitle;
  final bool addedWorks;
  final bool identityAuthenticated;
  final bool bankAccountAdded;
  final String? bio;
  final List<String> skills;
  final Statistics? statistics;
  final List<FreelancerReview> reviews;
  final List<Work> works;

  factory FreelancerProfileModel.fromJson(Map<String, dynamic> json) {
    return FreelancerProfileModel(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      country: json["country"],
      specialization: json["specialization"],
      jobTitle: json["job_title"],
      addedWorks: _toBool(json["added_works"]),
      identityAuthenticated: _toBool(json["identity_authenticated"]),
      bankAccountAdded: _toBool(json["bank_account_added"]),
      bio: json["bio"],
      skills: json["skills"] == null
          ? []
          : List<String>.from(json["skills"]!.map((x) => x)),
      statistics: json["statistics"] == null
          ? null
          : Statistics.fromJson(json["statistics"]),
      reviews: json["reviews"] == null
          ? []
          : List<FreelancerReview>.from(
              json["reviews"]!.map((x) => FreelancerReview.fromJson(x)),
            ),
      works: json["works"] == null
          ? []
          : List<Work>.from(json["works"]!.map((x) => Work.fromJson(x))),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return FreelancerProfileModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

class FreelancerReview {
  FreelancerReview({
    required this.id,
    required this.raterId,
    required this.image,
    required this.name,
    required this.jobTitle,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final int? id;
  final int? raterId;
  final String? image;
  final String? name;
  final String? jobTitle;
  final double rating;
  final String? comment;
  final String? date;

  factory FreelancerReview.fromJson(Map<String, dynamic> json) {
    return FreelancerReview(
      id: json["id"] is int
          ? json["id"] as int
          : int.tryParse(json["id"]?.toString() ?? ''),
      raterId: json["rater_id"] is int
          ? json["rater_id"] as int
          : int.tryParse(json["rater_id"]?.toString() ?? ''),
      image: json["image"]?.toString(),
      name: json["name"]?.toString(),
      jobTitle: json["job_title"]?.toString(),
      rating: double.tryParse(json["rating"]?.toString() ?? '') ?? 0,
      comment: json["comment"]?.toString(),
      date: json["date"]?.toString(),
    );
  }
}

class Statistics {
  Statistics({
    required this.rating,
    required this.identityAuthenticated,
    required this.bankAccountAdded,
    required this.completedProjects,
    required this.inProgressProjects,
    required this.city,
    required this.projectsCompletion,
    required this.deliverOnDate,
    required this.reEmployee,
    required this.ontimeSuccess,
    required this.replaySpeedAverage,
    required this.registrationDate,
    required this.lastSeen,
  });

  final int? rating;
  final bool identityAuthenticated;
  final bool bankAccountAdded;
  final int? completedProjects;
  final int? inProgressProjects;
  final String? city;
  final String? projectsCompletion;
  final String? deliverOnDate;
  final String? reEmployee;
  final String? ontimeSuccess;
  final String? replaySpeedAverage;
  final String? registrationDate;
  final String? lastSeen;

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      rating: json["rating"],
      identityAuthenticated: _toBool(json["identity_authenticated"]),
      bankAccountAdded: _toBool(json["bank_account_added"]),
      completedProjects: json["completed_projects"] is int
          ? json["completed_projects"] as int
          : int.tryParse(json["completed_projects"]?.toString() ?? ''),
      inProgressProjects: json["in_progress_projects"] is int
          ? json["in_progress_projects"] as int
          : int.tryParse(json["in_progress_projects"]?.toString() ?? ''),
      city: json["city"]?.toString(),
      projectsCompletion: json["projects_completion"],
      deliverOnDate: json["deliver_on_date"],
      reEmployee: json["re_employee"],
      ontimeSuccess: json["ontime_success"],
      replaySpeedAverage: json["replay_speed_average"],
      registrationDate: json["registration_date"],
      lastSeen: json["last_seen"],
    );
  }
}

class Work {
  Work({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.views,
    required this.likes,
    required this.status,
    required this.isInFavorites,
  });

  final int? id;
  final String? image;
  final String? title;
  final String? description;
  final int? views;
  final int? likes;
  final String? status;
  final bool? isInFavorites;

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json["id"],
      image: json["image"],
      title: json["title"],
      description: json["description"],
      views: json["views"],
      likes: json["likes"],
      status: json["status"],
      isInFavorites: json["is_in_favorites"] == true ||
          json["is_in_favorites"] == 1 ||
          json["is_in_favorites"]?.toString() == "1",
    );
  }
}
