import 'dart:io';

import 'package:dio/dio.dart';

class CreateContractRequestModel {
  const CreateContractRequestModel({
    required this.projectId,
    required this.userId,
    this.conversationId,
    required this.date,
    required this.title,
    required this.budget,
    required this.duration,
    required this.terms,
    this.notes,
    this.files = const [],
  });

  final int projectId;
  final int userId;
  final int? conversationId;
  final String date;
  final String title;
  final String budget;
  final String duration;
  final String terms;
  final String? notes;
  final List<File> files;

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'user_id': userId,
      if (conversationId != null) 'conversation_id': conversationId,
      'date': date,
      'title': title,
      'budget': budget,
      'duration': duration,
      'terms': terms,
      'notes': notes ?? '',
    };
  }

  Future<FormData> toFormData() async {
    final formData = FormData();

    for (final entry in toJson().entries) {
      formData.fields.add(
        MapEntry(entry.key, entry.value?.toString() ?? ''),
      );
    }

    for (var i = 0; i < files.length; i++) {
      formData.files.add(
        MapEntry(
          'files[$i]',
          await MultipartFile.fromFile(files[i].path),
        ),
      );
    }

    return formData;
  }
}
