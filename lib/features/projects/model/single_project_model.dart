import 'package:talent_flow/data/config/mapper.dart';

class SingleProjectModel extends SingleMapper{
  SingleProjectModel({
    required this.views,
    required this.since,
    required this.status,
    required this.duration,
    required this.budget,
    required this.skills,
    required this.owner,
    required this.title,
    required this.description,
    required this.filesDescription,
    required this.similarProjects,
    required this.requiredToBeReceived,
    required this.files,
  });

  final int? views;
  final String? since;
  final String? status;
  final int? duration;
  final String? budget;
  final List<String> skills;
  final Owner? owner;
  final String? title;
  final String? description;
  final dynamic filesDescription;
  final dynamic similarProjects;
  final dynamic requiredToBeReceived;
  final List<dynamic> files;

  factory SingleProjectModel.fromJson(Map<String, dynamic> json){
    return SingleProjectModel(
      views: json["views"],
      since: json["since"],
      status: json["status"],
      duration: json["duration"],
      budget: json["budget"],
      skills: json["skills"] == null ? [] : List<String>.from(json["skills"]!.map((x) => x)),
      owner: json["owner"] == null ? null : Owner.fromJson(json["owner"]),
      title: json["title"],
      description: json["description"],
      filesDescription: json["files_description"],
      similarProjects: json["similar_projects"],
      requiredToBeReceived: json["required_to_be_received"],
      files: json["files"] == null ? [] : List<dynamic>.from(json["files"]!.map((x) => x)),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
   return SingleProjectModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}

class Owner {
  Owner({
    required this.id,
    required this.name,
    required this.image,
    required this.jobTitle,
    required this.signupDate,
    required this.employmentRate,
    required this.openProjectsCount,
    required this.underImplementationCount,
    required this.ongoingCommunications,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;
  final String? signupDate;
  final int? employmentRate;
  final int? openProjectsCount;
  final int? underImplementationCount;
  final int? ongoingCommunications;

  factory Owner.fromJson(Map<String, dynamic> json){
    return Owner(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      jobTitle: json["job_title"],
      signupDate: json["signup_date"],
      employmentRate: json["employment_rate"],
      openProjectsCount: json["open_projects_count"],
      underImplementationCount: json["under_implementation_count"],
      ongoingCommunications: json["ongoing_communications"],
    );
  }

}
