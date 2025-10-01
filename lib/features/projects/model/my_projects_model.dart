import 'package:talent_flow/data/config/mapper.dart';

class MyProjectsModel extends SingleMapper {
  MyProjectsModel({
    required this.id,
     this.owner,
    required this.title,
    required this.description,
    required this.views,
     this.since,
     this.proposalsCount,
    required this.status,
     this.isPaid,
     this.specialization,
     this.isInFavorites,
  });

  final int? id;
  final Owner? owner;
  final String? title;
  final String? description;
  final int? views;
  final String? since;
  final int? proposalsCount;
  final String? status;
  final int? isPaid;
  final Specialization? specialization;
  final bool? isInFavorites;

  factory MyProjectsModel.fromJson(Map<String, dynamic> json) {
    return MyProjectsModel(
      id: json["id"],
      owner: json["owner"] == null ? null : Owner.fromJson(json["owner"]),
      title: json["title"],
      description: json["description"],
      views: json["views"] ?? 0,
      since: json["since"] ?? "",

      // 🔹 Handle both "proposals_count" and "likes"
      proposalsCount: json["proposals_count"] ?? json["likes"] ?? 0,

      status: json["status"],
      isPaid: json["is_paid"] ?? 0,

      // 🔹 If specialization is missing, fallback to using image/title
      specialization: json["specialization"] == null
          ? (json["image"] != null
          ? Specialization(
        name: json["specialization_name"] ?? "", // optional
        image: json["image"],
      )
          : null)
          : Specialization.fromJson(json["specialization"]),

      isInFavorites: json["is_in_favorites"] ?? false,
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
