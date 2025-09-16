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
    String? filesDescription,
    List<String>? similarProjects,
    bool requiredToBeReceived = false,
    List<ProjectQuestion>? questions,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'specialization_id': specializationId,
        'title': title,
        'description': description,
        'skills': skills,
        'budget': budget,
        'duration': duration,
        'required_to_be_received': requiredToBeReceived,
      };

      // Add optional fields only if they have values
      if (filesDescription != null && filesDescription.isNotEmpty) {
        data['files_description'] = filesDescription;
      }

      if (similarProjects != null && similarProjects.isNotEmpty) {
        data['similar_projects'] = similarProjects;
      }

      if (questions != null && questions.isNotEmpty) {
        data['questions'] = questions.map((q) =>
        {
          'question': q.question,
          'required': q.isRequired ? 1 : 0,
          // Convert bool to int if your API expects int
        }).toList();
      }

      final response = await dioClient.post(
        uri: EndPoints.addProject,
        data: data,
      );

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