import 'package:talent_flow/data/config/mapper.dart'; // Assuming SingleMapper is defined here

class MyProjectsModel extends SingleMapper {
  MyProjectsModel({
    required this.id,
    required this.owner,
    required this.title,
    required this.description,
    required this.views,
    required this.since,
    required this.proposalsCount,
    required this.status, // Added
    required this.isPaid, // Added
    required this.specialization, // Added
    required this.isInFavorites,
  });

  final int? id;
  final Owner? owner;
  final String? title;
  final String? description;
  final int? views;
  final String? since;
  final int? proposalsCount;
  final String? status; // Added
  final int? isPaid; // Added
  final Specialization? specialization; // Added
  final bool? isInFavorites;

  factory MyProjectsModel.fromJson(Map<String, dynamic> json) {
    return MyProjectsModel(
      id: json["id"],
      owner: json["owner"] == null ? null : Owner.fromJson(json["owner"]),
      title: json["title"],
      description: json["description"],
      views: json["views"],
      since: json["since"],
      proposalsCount: json["proposals_count"],
      status: json["status"], // Added
      isPaid: json["is_paid"], // Added
      specialization: json["specialization"] == null
          ? null
          : Specialization.fromJson(json["specialization"]), // Added
      isInFavorites: json["is_in_favorites"],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return MyProjectsModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "owner": owner?.toJson(),
      "title": title,
      "description": description,
      "views": views,
      "since": since,
      "proposals_count": proposalsCount,
      "status": status,
      "is_paid": isPaid,
      "specialization": specialization?.toJson(),
      "is_in_favorites": isInFavorites,
    };
  }
}

class Owner extends SingleMapper {
  Owner({
    required this.id,
    required this.name,
    required this.image,
    required this.jobTitle,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      jobTitle: json["job_title"],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return Owner.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "job_title": jobTitle,
    };
  }
}

// New Model for Specialization
class Specialization extends SingleMapper {
  Specialization({
    required this.name,
    required this.image,
  });

  final String? name;
  final String? image;

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      name: json["name"],
      image: json["image"],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return Specialization.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "image": image,
    };
  }
}
