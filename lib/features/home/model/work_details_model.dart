import 'package:talent_flow/data/config/mapper.dart';

import 'freelancer_profile_model.dart';

class WorkDetailsModel extends SingleMapper {
  WorkDetailsModel({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.views,
    required this.likes,
    required this.status,
    required this.date,
    required this.previewLink,
    required this.files,
    required this.skills,
    required this.isInFavorites,
  });

  final int? id;
  final String? image;
  final String? title;
  final String? description;
  final int? views;
  final int? likes;
  final String? status;
  final String? date;
  final String? previewLink;
  final List<String> files;
  final List<String> skills;
  final bool? isInFavorites;

  factory WorkDetailsModel.fromJson(Map<String, dynamic> json) {
    return WorkDetailsModel(
      id: _toInt(json['id']),
      image: _asString(json['image']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      views: _toInt(json['views']),
      likes: _toInt(json['likes']),
      status: _asString(json['status']) ?? _asString(json['status_text']),
      date: _asString(json['date']) ?? _asString(json['created_at']),
      previewLink:
          _asString(json['preview_link']) ?? _asString(json['previewLink']),
      files: _extractFiles(json['files'] ?? json['attachments']),
      skills: _extractStrings(json['skills']),
      isInFavorites: json['is_in_favorites'] == true ||
          json['is_in_favorites'] == 1 ||
          json['is_in_favorites']?.toString() == '1',
    );
  }

  factory WorkDetailsModel.fromWork(Work work) {
    return WorkDetailsModel(
      id: work.id,
      image: work.image,
      title: work.title,
      description: work.description,
      views: work.views,
      likes: work.likes,
      status: work.status,
      date: null,
      previewLink: null,
      files: const [],
      skills: const [],
      isInFavorites: work.isInFavorites,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  static List<String> _extractFiles(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) {
          if (item is String) return item.trim();
          if (item is Map<String, dynamic>) {
            return _asString(item['url']) ??
                _asString(item['file']) ??
                _asString(item['path']) ??
                '';
          }
          return item.toString().trim();
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<String> _extractStrings(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) {
          if (item is String) return item.trim();
          if (item is Map<String, dynamic>) {
            return _asString(item['name']) ??
                _asString(item['title']) ??
                _asString(item['label']) ??
                '';
          }
          return item.toString().trim();
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return WorkDetailsModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'description': description,
      'views': views,
      'likes': likes,
      'status': status,
      'date': date,
      'preview_link': previewLink,
      'files': files,
      'skills': skills,
      'is_in_favorites': isInFavorites,
    };
  }
}
