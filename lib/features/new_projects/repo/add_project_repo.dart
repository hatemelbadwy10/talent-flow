import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class ProjectRepository extends BaseRepo {
  ProjectRepository(
      {required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> addProject({
    required int specializationId,
    required String title,
    required String description,
    required List<int> skills,
    required String budget,
    required int duration,
    List<File>? files,
    String? filesDescription,
    List<String>? similarProjects,
    String? requiredToBeReceived,
    List<ProjectQuestion>? questions,
  }) async {
    try {
      final hasFiles = files != null && files.isNotEmpty;
      final normalizedRequiredToBeReceived = requiredToBeReceived?.trim();

      late final Response response;

      if (hasFiles) {
        final formData = FormData();

        formData.fields.add(MapEntry('specialization_id', '$specializationId'));
        formData.fields.add(MapEntry('title', title));
        formData.fields.add(MapEntry('description', description));
        formData.fields.add(MapEntry('budget', budget));
        formData.fields.add(MapEntry('duration', '$duration'));

        for (int index = 0; index < skills.length; index++) {
          formData.fields.add(MapEntry('skills[$index]', '${skills[index]}'));
        }

        if (normalizedRequiredToBeReceived != null &&
            normalizedRequiredToBeReceived.isNotEmpty) {
          formData.fields.add(
            MapEntry(
              'required_to_be_received',
              normalizedRequiredToBeReceived,
            ),
          );
        }

        if (filesDescription != null && filesDescription.trim().isNotEmpty) {
          formData.fields.add(
            MapEntry('files_description', filesDescription.trim()),
          );
        }

        if (similarProjects != null && similarProjects.isNotEmpty) {
          for (int index = 0; index < similarProjects.length; index++) {
            formData.fields.add(
              MapEntry('similar_projects[$index]', similarProjects[index]),
            );
          }
        }

        if (questions != null && questions.isNotEmpty) {
          for (int index = 0; index < questions.length; index++) {
            formData.fields.add(
              MapEntry(
                  'questions[$index][question]', questions[index].question),
            );
            formData.fields.add(
              MapEntry(
                'questions[$index][required]',
                questions[index].isRequired ? '1' : '0',
              ),
            );
          }
        }

        for (int index = 0; index < files.length; index++) {
          formData.files.add(
            MapEntry(
              'files[$index]',
              await MultipartFile.fromFile(files[index].path),
            ),
          );
        }

        response = await dioClient.post(
          uri: EndPoints.addProject,
          data: formData,
        );
      } else {
        final Map<String, dynamic> data = {
          'specialization_id': specializationId,
          'title': title,
          'description': description,
          'skills': skills,
          'budget': budget,
          'duration': duration,
        };

        if (normalizedRequiredToBeReceived != null &&
            normalizedRequiredToBeReceived.isNotEmpty) {
          data['required_to_be_received'] = normalizedRequiredToBeReceived;
        }

        if (filesDescription != null && filesDescription.trim().isNotEmpty) {
          data['files_description'] = filesDescription.trim();
        }

        if (similarProjects != null && similarProjects.isNotEmpty) {
          data['similar_projects'] = similarProjects;
        }

        if (questions != null && questions.isNotEmpty) {
          data['questions'] = questions
              .map((q) => {
                    'question': q.question,
                    'required': q.isRequired ? 1 : 0,
                  })
              .toList();
        }

        response = await dioClient.post(
          uri: EndPoints.addProject,
          data: data,
        );
      }

      return Right(response);
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }
}

class ProjectQuestion {
  final String question;
  final bool isRequired;

  ProjectQuestion({
    required this.question,
    required this.isRequired,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'required': isRequired ? 1 : 0,
    };
  }

  factory ProjectQuestion.fromJson(Map<String, dynamic> json) {
    return ProjectQuestion(
      question: json['question'] ?? '',
      isRequired: (json['required'] == 1) || (json['required'] == true),
    );
  }
}
