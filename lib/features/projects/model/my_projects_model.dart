import 'package:talent_flow/data/config/mapper.dart';

class MyProjectsModel extends SingleMapper {
  MyProjectsModel({
    this.id,
    this.owner,
    this.title,
    this.description,
    this.views,
    this.since,
    this.proposalsCount,
    this.status,
    this.isPaid,
    this.specialization,
    this.isInFavorites,
    this.date
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
  final String? date;

  factory MyProjectsModel.fromJson(Map<String, dynamic> json) {
    final ownerMap = _toMap(json['owner']);
    final specializationMap = _toMap(json['specialization']);
    final fallbackSpecializationImage = _toText(json['image']);
    final fallbackSpecializationName =
        _toText(json['specialization_name']) ?? _toText(json['name']);

    return MyProjectsModel(
      id: _toInt(json['id']),
      owner: ownerMap != null
          ? Owner.fromJson(ownerMap)
          : Owner.fallbackFromProjectJson(json),
      title: _toText(json['title']),
      description: _toText(json['description']),
      views: _toInt(json['views']) ?? 0,
      since: _toText(json['since']) ?? '',
      proposalsCount: _toInt(json['proposals_count'] ?? json['likes']) ?? 0,
      status: _toText(json['status']),
      isPaid: _toInt(json['is_paid']),
      specialization: specializationMap != null
          ? Specialization.fromJson(specializationMap)
          : (fallbackSpecializationImage != null ||
                  fallbackSpecializationName != null)
              ? Specialization(
                  name: fallbackSpecializationName,
                  image: fallbackSpecializationImage,
                )
              : null,
      isInFavorites: _toBool(json['is_in_favorites']) ?? false,
      date: _toText(json['date']),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return MyProjectsModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner?.toJson(),
      'title': title,
      'description': description,
      'views': views,
      'since': since,
      'proposals_count': proposalsCount,
      'status': status,
      'is_paid': isPaid,
      'specialization': specialization?.toJson(),
      'is_in_favorites': isInFavorites,
    };
  }
}

class Owner extends SingleMapper {
  Owner({
    this.id,
    this.name,
    this.image,
    this.jobTitle,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: _toInt(json['id']),
      name: _toText(json['name']),
      image: _toText(json['image']),
      jobTitle: _toText(json['job_title']),
    );
  }

  factory Owner.fallbackFromProjectJson(Map<String, dynamic> json) {
    final name = _toText(json['owner_name']) ?? _toText(json['user_name']);
    final image = _toText(json['owner_image']) ?? _toText(json['user_image']);
    final jobTitle =
        _toText(json['owner_job_title']) ?? _toText(json['user_job_title']);

    if (name == null && image == null && jobTitle == null) {
      return Owner();
    }

    return Owner(
      id: _toInt(json['owner_id']) ?? _toInt(json['user_id']),
      name: name,
      image: image,
      jobTitle: jobTitle,
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return Owner.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'job_title': jobTitle,
    };
  }
}

class Specialization extends SingleMapper {
  Specialization({
    this.name,
    this.image,
  });

  final String? name;
  final String? image;

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      name: _toText(json['name']),
      image: _toText(json['image']),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return Specialization.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is bool) {
    return value ? 1 : 0;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _toText(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }
  return text;
}

bool? _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final text = value?.toString().toLowerCase();
  if (text == 'true' || text == '1') {
    return true;
  }
  if (text == 'false' || text == '0') {
    return false;
  }
  return null;
}
