import 'package:talent_flow/data/config/mapper.dart';

class ContractModel implements Mapper {
  ContractModel({
    required this.id,
    required this.title,
    required this.status,
    required this.statusLabel,
    this.projectId,
    this.projectOwnerId,
    this.freelancerId,
    this.rejectWorkNotes,
    this.rejectReason,
    this.userHasSubmittedComplaint = false,
    this.userHasSubmittedReview = false,
    this.projectTitle,
    this.projectDescription,
    this.projectOwner,
    this.freelancer,
    this.date,
    this.budget,
    this.duration,
    this.terms,
    this.talentPercentageOfContracts,
    this.terminationConditions,
    this.conflictPolicy,
  });

  final int? id;
  final String? title;
  final int? status;
  final String? statusLabel;
  final int? projectId;
  final int? projectOwnerId;
  final int? freelancerId;
  final String? rejectWorkNotes;
  final String? rejectReason;
  final bool userHasSubmittedComplaint;
  final bool userHasSubmittedReview;
  final String? projectTitle;
  final String? projectDescription;
  final String? projectOwner;
  final String? freelancer;
  final String? date;
  final String? budget;
  final String? duration;
  final String? terms;
  final String? talentPercentageOfContracts;
  final String? terminationConditions;
  final String? conflictPolicy;

  bool get isPayableForOwner {
    return status == 1;
  }

  String get suggestedPaymentAmount {
    final source = (budget?.trim() ?? '').replaceAll(',', '');
    if (source.isEmpty) return '';
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(source);
    return match?.group(0) ?? source;
  }

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title']?.toString(),
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? ''),
      statusLabel: json['status_label']?.toString(),
      projectId: json['project_id'] is int
          ? json['project_id'] as int
          : int.tryParse(json['project_id']?.toString() ?? ''),
      projectOwnerId: json['project_owner_id'] is int
          ? json['project_owner_id'] as int
          : int.tryParse(json['project_owner_id']?.toString() ?? ''),
      freelancerId: json['freelancer_id'] is int
          ? json['freelancer_id'] as int
          : int.tryParse(json['freelancer_id']?.toString() ?? ''),
      rejectWorkNotes: json['reject_work_notes']?.toString(),
      rejectReason: json['reject_reason']?.toString(),
      userHasSubmittedComplaint: _toBool(json['user_has_submitted_complaint']),
      userHasSubmittedReview: _toBool(json['user_has_submitted_review']),
      projectTitle: json['project_title']?.toString(),
      projectDescription: json['project_description']?.toString(),
      projectOwner: json['project_owner']?.toString(),
      freelancer: json['freelancer']?.toString(),
      date: json['date']?.toString(),
      budget: json['budget']?.toString(),
      duration: json['duration']?.toString(),
      terms: json['terms']?.toString(),
      talentPercentageOfContracts:
          json['talent_percentage_of_contracts']?.toString(),
      terminationConditions: json['termination_conditions']?.toString(),
      conflictPolicy: json['conflict_policy']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'status_label': statusLabel,
      'project_id': projectId,
      'project_owner_id': projectOwnerId,
      'freelancer_id': freelancerId,
      'reject_work_notes': rejectWorkNotes,
      'reject_reason': rejectReason,
      'user_has_submitted_complaint': userHasSubmittedComplaint,
      'user_has_submitted_review': userHasSubmittedReview,
      'project_title': projectTitle,
      'project_description': projectDescription,
      'project_owner': projectOwner,
      'freelancer': freelancer,
      'date': date,
      'budget': budget,
      'duration': duration,
      'terms': terms,
      'talent_percentage_of_contracts': talentPercentageOfContracts,
      'termination_conditions': terminationConditions,
      'conflict_policy': conflictPolicy,
    };
  }
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
