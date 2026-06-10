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
    required this.questions,
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
  final List<ProjectQuestionDetail> questions;
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
      questions: json["questions"] == null
          ? []
          : List<ProjectQuestionDetail>.from(
              json["questions"]!.map((x) => ProjectQuestionDetail.fromJson(x)),
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
    required this.questionsAnswers,
  });

  final int? id;
  final int? freelancerId;
  final String? freelancerImage;
  final String? freelancerName;
  final String? freelancerJobTitle;
  final double? freelancerRating;
  final String? since;
  final String? description;
  final List<ProjectQuestionAnswer> questionsAnswers;

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
      questionsAnswers: json["questions_answers"] == null
          ? []
          : List<ProjectQuestionAnswer>.from(
              json["questions_answers"]!
                  .map((x) => ProjectQuestionAnswer.fromJson(x)),
            ),
    );
  }
}

class ProjectQuestionDetail {
  const ProjectQuestionDetail({
    required this.id,
    required this.question,
    required this.isRequired,
  });

  final int? id;
  final String? question;
  final bool isRequired;

  factory ProjectQuestionDetail.fromJson(Map<String, dynamic> json) {
    return ProjectQuestionDetail(
      id: _toInt(json["id"]),
      question: json["question"]?.toString(),
      isRequired: _toBool(json["required"]),
    );
  }
}

class ProjectQuestionAnswer {
  const ProjectQuestionAnswer({
    required this.questionId,
    required this.answer,
  });

  final int? questionId;
  final String? answer;

  factory ProjectQuestionAnswer.fromJson(Map<String, dynamic> json) {
    final question = json["question"];
    return ProjectQuestionAnswer(
      questionId: _toInt(
        json["question_id"] ??
            (question is Map ? question["id"] : null) ??
            json["id"],
      ),
      answer: json["answer"]?.toString(),
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

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == '1' || normalized == 'true' || normalized == 'yes';
}
