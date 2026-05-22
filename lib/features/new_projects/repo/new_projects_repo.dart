import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class NewProjectsRepo extends BaseRepo {
  NewProjectsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getProjects({
    int? specializationId,
    String? sortBy,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (specializationId != null) {
        queryParameters['specialization'] = specializationId;
      }
      if (sortBy != null && sortBy.trim().isNotEmpty) {
        queryParameters['sortBy'] = sortBy.trim();
      }

      final response = await dioClient.get(
        uri: EndPoints.projects,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> addOffer(int id, String offer) async {
    return addOfferWithAnswers(
      projectId: id,
      offer: offer,
      answers: const [],
    );
  }

  Future<Either<ServerFailure, Response>> addOfferWithAnswers({
    required int projectId,
    required String offer,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('project_id', '$projectId'));
      formData.fields.add(MapEntry('description', offer));
      for (var i = 0; i < answers.length; i++) {
        final questionId = answers[i]['question_id'];
        final answer = answers[i]['answer']?.toString() ?? '';
        formData.fields.add(
          MapEntry('questions_answers[$i][question_id]', '$questionId'),
        );
        formData.fields.add(
          MapEntry('questions_answers[$i][answer]', answer),
        );
      }
      final response = await dioClient.post(
        uri: EndPoints.addOffer,
        data: formData,
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> updateOffer({
    required int proposalId,
    required int projectId,
    required String offer,
    List<Map<String, dynamic>> answers = const [],
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('project_id', '$projectId'));
      formData.fields.add(MapEntry('description', offer));
      for (var i = 0; i < answers.length; i++) {
        final questionId = answers[i]['question_id'];
        final answer = answers[i]['answer']?.toString() ?? '';
        formData.fields.add(
          MapEntry('questions_answers[$i][question_id]', '$questionId'),
        );
        formData.fields.add(
          MapEntry('questions_answers[$i][answer]', answer),
        );
      }

      try {
        final response = await dioClient.put(
          uri: EndPoints.projectProposal(proposalId),
          data: formData,
        );
        return Right(response);
      } catch (_) {
        final response = await dioClient.post(
          uri: EndPoints.projectProposal(proposalId),
          data: formData,
        );
        return Right(response);
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<Failure, dynamic>> addRemoveFavorite(int id) async {
    try {
      final response = await dioClient.get(uri: "${EndPoints.projects}/$id/favourite");
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
