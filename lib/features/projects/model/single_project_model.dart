import 'package:talent_flow/data/config/mapper.dart';

class SingleProjectModel extends SingleMapper {
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
    required this.proposals,
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
  final List<ProjectProposal> proposals;
  final List<dynamic> files;

  factory SingleProjectModel.fromJson(Map<String, dynamic> json) {
    return SingleProjectModel(
      views: json["views"],
      since: json["since"],
      status: json["status"],
      duration: json["duration"],
      budget: json["budget"],
      skills: json["skills"] == null
          ? []
          : List<String>.from(json["skills"]!.map((x) => x)),
      owner: json["owner"] == null ? null : Owner.fromJson(json["owner"]),
      title: json["title"],
      description: json["description"],
      filesDescription: json["files_description"],
      similarProjects: json["similar_projects"],
      requiredToBeReceived: json["required_to_be_received"],
      proposals: json["proposals"] == null
          ? []
          : List<ProjectProposal>.from(
              json["proposals"]!.map((x) => ProjectProposal.fromJson(x)),
            ),
      files: _extractFiles(json["files"] ?? json["attachments"]),
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

  static List<dynamic> _extractFiles(dynamic value) {
    if (value is List) {
      return List<dynamic>.from(value);
    }

    if (value == null) {
      return const [];
    }

    final normalizedValue = value.toString().trim();
    if (normalizedValue.isEmpty) {
      return const [];
    }

    return [normalizedValue];
  }
}

class ProjectProposal {
  ProjectProposal({
    required this.id,
    required this.freelancerId,
    required this.freelancerImage,
    required this.freelancerName,
    required this.freelancerJobTitle,
    required this.freelancerRating,
    required this.since,
    required this.description,
  });

  final int? id;
  final int? freelancerId;
  final String? freelancerImage;
  final String? freelancerName;
  final String? freelancerJobTitle;
  final double? freelancerRating;
  final String? since;
  final String? description;

  factory ProjectProposal.fromJson(Map<String, dynamic> json) {
    return ProjectProposal(
      id: json["id"],
      freelancerId: json["freelancer_id"],
      freelancerImage: json["freelancer_image"],
      freelancerName: json["freelancer_name"],
      freelancerJobTitle: json["freelancer_job_title"],
      freelancerRating: (json["freelancer_rating"] as num?)?.toDouble(),
      since: json["since"],
      description: json["description"],
    );
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
  final String? employmentRate;
  final int? openProjectsCount;
  final int? underImplementationCount;
  final int? ongoingCommunications;

  factory Owner.fromJson(Map<String, dynamic> json) {
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
