import 'package:talent_flow/data/config/mapper.dart';

class EntrepreneurProfileModel extends SingleMapper {
  EntrepreneurProfileModel({
    required this.id,
    required this.name,
    required this.image,
    required this.jobTitle,
    required this.bio,
    required this.country,
    required this.specialization,
    required this.rating,
    required this.noOfReviews,
    required this.statistics,
    required this.reviews,
    required this.projects,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;
  final String? bio;
  final String? country;
  final String? specialization;
  final double rating;
  final int noOfReviews;
  final EntrepreneurStatistics? statistics;
  final List<EntrepreneurReview> reviews;
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
      country: json['country']?.toString(),
      specialization: json['specialization']?.toString(),
      rating: double.tryParse(
            (json['rating'] ?? json['statistics']?['rating'])?.toString() ?? '',
          ) ??
          0,
      noOfReviews: _entrepreneurToInt(
            json['no_of_reviews'] ??
                json['reviews_count'] ??
                json['reviews']?.length,
          ) ??
          0,
      statistics: json['statistics'] is Map<String, dynamic>
          ? EntrepreneurStatistics.fromJson(
              json['statistics'] as Map<String, dynamic>,
            )
          : null,
      reviews: json['reviews'] is List
          ? (json['reviews'] as List)
              .whereType<Map<String, dynamic>>()
              .map(EntrepreneurReview.fromJson)
              .toList()
          : const [],
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

class EntrepreneurReview {
  const EntrepreneurReview({
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

  factory EntrepreneurReview.fromJson(Map<String, dynamic> json) {
    return EntrepreneurReview(
      id: _entrepreneurToInt(json['id']),
      raterId: _entrepreneurToInt(json['rater_id']),
      image: json['image']?.toString(),
      name: json['name']?.toString(),
      jobTitle: json['job_title']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString(),
      date: json['date']?.toString(),
    );
  }
}

class EntrepreneurStatistics {
  const EntrepreneurStatistics({
    required this.rating,
    required this.registrationDate,
    required this.lastSeen,
    required this.openProjectsCount,
    required this.underImplementationCount,
    required this.ongoingCommunications,
    required this.city,
  });

  final double rating;
  final String? registrationDate;
  final String? lastSeen;
  final int? openProjectsCount;
  final int? underImplementationCount;
  final int? ongoingCommunications;
  final String? city;

  factory EntrepreneurStatistics.fromJson(Map<String, dynamic> json) {
    return EntrepreneurStatistics(
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      registrationDate: json['registration_date']?.toString(),
      lastSeen: json['last_seen']?.toString(),
      openProjectsCount: _entrepreneurToInt(
        json['open_projects_count'] ?? json['completed_projects'],
      ),
      underImplementationCount: _entrepreneurToInt(
        json['under_implementation_count'] ?? json['in_progress_projects'],
      ),
      ongoingCommunications: _entrepreneurToInt(json['ongoing_communications']),
      city: json['city']?.toString(),
    );
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
      count: _entrepreneurToInt(
        json['count'] ??
            json['value'] ??
            json['projects_count'] ??
            json['total'],
      ),
    );
  }
}

int? _entrepreneurToInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
