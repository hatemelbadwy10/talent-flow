import 'package:talent_flow/data/config/mapper.dart';

class ContractModel implements Mapper {
  ContractModel({
    required this.id,
    required this.title,
    required this.status,
    required this.statusLabel,
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
