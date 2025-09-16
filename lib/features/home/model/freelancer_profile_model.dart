import 'package:talent_flow/data/config/mapper.dart';

class FreelancerProfileModel extends SingleMapper{
  FreelancerProfileModel({
    required this.id,
    required this.name,
    required this.image,
    required this.country,
    required this.specialization,
    required this.jobTitle,
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
  final String? bio;
  final List<String> skills;
  final Statistics? statistics;
  final List<dynamic> reviews;
  final List<Work> works;

  factory FreelancerProfileModel.fromJson(Map<String, dynamic> json){
    return FreelancerProfileModel(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      country: json["country"],
      specialization: json["specialization"],
      jobTitle: json["job_title"],
      bio: json["bio"],
      skills: json["skills"] == null ? [] : List<String>.from(json["skills"]!.map((x) => x)),
      statistics: json["statistics"] == null ? null : Statistics.fromJson(json["statistics"]),
      reviews: json["reviews"] == null ? [] : List<dynamic>.from(json["reviews"]!.map((x) => x)),
      works: json["works"] == null ? [] : List<Work>.from(json["works"]!.map((x) => Work.fromJson(x))),
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

class Statistics {
  Statistics({
    required this.rating,
    required this.projectsCompletion,
    required this.deliverOnDate,
    required this.reEmployee,
    required this.ontimeSuccess,
    required this.replaySpeedAverage,
    required this.registrationDate,
    required this.lastSeen,
  });

  final int? rating;
  final String? projectsCompletion;
  final String? deliverOnDate;
  final String? reEmployee;
  final String? ontimeSuccess;
  final String? replaySpeedAverage;
  final String? registrationDate;
  final String? lastSeen;

  factory Statistics.fromJson(Map<String, dynamic> json){
    return Statistics(
      rating: json["rating"],
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
  });

  final int? id;
  final String? image;
  final String? title;
  final String? description;
  final int? views;
  final int? likes;
  final String? status;

  factory Work.fromJson(Map<String, dynamic> json){
    return Work(
      id: json["id"],
      image: json["image"],
      title: json["title"],
      description: json["description"],
      views: json["views"],
      likes: json["likes"],
      status: json["status"],
    );
  }

}
