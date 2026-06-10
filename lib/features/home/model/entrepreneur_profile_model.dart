import 'package:talent_flow/data/config/mapper.dart';

class EntrepreneurProfileModel extends SingleMapper {
  EntrepreneurProfileModel({
    required this.id,
    required this.name,
    required this.image,
    required this.jobTitle,
    required this.bio,
    required this.identityAuthenticated,
    required this.bankAccountAdded,
    required this.projects,
    required this.reviews,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;
  final String? bio;
  final bool identityAuthenticated;
  final bool bankAccountAdded;
  final List<EntrepreneurProjectStatus> projects;
  final List<EntrepreneurReview> reviews;

  int get totalProjects =>
      projects.fold<int>(0, (sum, item) => sum + (item.count ?? 0));

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  factory EntrepreneurProfileModel.fromJson(Map<String, dynamic> json) {
    return EntrepreneurProfileModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      jobTitle: json['job_title']?.toString(),
      bio: json['bio']?.toString(),
      identityAuthenticated: _toBool(json['identity_authenticated']),
      bankAccountAdded: _toBool(
        json['bank_account_added'] ?? json['has_bank_account'],
      ),
      projects: json['projects'] is List
          ? (json['projects'] as List)
              .whereType<Map<String, dynamic>>()
              .map(EntrepreneurProjectStatus.fromJson)
              .toList()
          : const [],
      reviews: json['reviews'] is List
          ? (json['reviews'] as List)
              .whereType<Map<String, dynamic>>()
              .map(EntrepreneurReview.fromJson)
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
      id: _toInt(json['id']),
      raterId: _toInt(json['rater_id']),
      image: json['image']?.toString(),
      name: json['name']?.toString(),
      jobTitle: json['job_title']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString(),
      date: json['date']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
