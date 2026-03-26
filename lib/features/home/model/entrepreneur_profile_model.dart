import 'package:talent_flow/data/config/mapper.dart';

class EntrepreneurProfileModel extends SingleMapper {
  EntrepreneurProfileModel({
    required this.id,
    required this.name,
    required this.image,
    required this.jobTitle,
    required this.bio,
    required this.projects,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;
  final String? bio;
  final List<EntrepreneurProjectStatus> projects;

  int get totalProjects =>
      projects.fold<int>(0, (sum, item) => sum + (item.count ?? 0));

  factory EntrepreneurProfileModel.fromJson(Map<String, dynamic> json) {
    return EntrepreneurProfileModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      jobTitle: json['job_title']?.toString(),
      bio: json['bio']?.toString(),
      projects: json['projects'] is List
          ? (json['projects'] as List)
              .whereType<Map<String, dynamic>>()
              .map(EntrepreneurProjectStatus.fromJson)
              .toList()
          : const [],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return EntrepreneurProfileModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class EntrepreneurProjectStatus {
  const EntrepreneurProjectStatus({
    required this.status,
    required this.count,
  });

  final String? status;
  final int? count;

  factory EntrepreneurProjectStatus.fromJson(Map<String, dynamic> json) {
    return EntrepreneurProjectStatus(
      status: json['status']?.toString(),
      count: _toInt(
        json['count'] ??
            json['value'] ??
            json['projects_count'] ??
            json['total'],
      ),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
