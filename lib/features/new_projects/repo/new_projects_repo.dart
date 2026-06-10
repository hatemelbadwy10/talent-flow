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
      final response = await dioClient.get(
        uri: EndPoints.projects,
        queryParameters: {
          if (specializationId != null) 'specialization': specializationId,
          if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
        },
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> addOffer(
    int id,
    String offer, {
    Map<int, String> questionAnswers = const {},
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.addOffer,
        queryParameters: _offerParameters(
          projectId: id,
          offer: offer,
          questionAnswers: questionAnswers,
        ),
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
    Map<int, String> questionAnswers = const {},
  }) async {
    try {
      final queryParameters = _offerParameters(
        projectId: projectId,
        offer: offer,
        questionAnswers: questionAnswers,
      );

      try {
        final response = await dioClient.put(
          uri: EndPoints.projectProposal(proposalId),
          queryParameters: queryParameters,
        );
        return Right(response);
      } catch (_) {
        final response = await dioClient.post(
          uri: EndPoints.projectProposal(proposalId),
          queryParameters: queryParameters,
        );
        return Right(response);
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<Failure, dynamic>> addRemoveFavorite(int id) async {
    try {
      final response =
          await dioClient.get(uri: "${EndPoints.projects}/$id/favourite");
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Map<String, dynamic> _offerParameters({
    required int projectId,
    required String offer,
    required Map<int, String> questionAnswers,
  }) {
    final parameters = <String, dynamic>{
      "project_id": projectId,
      "description": offer,
    };

    final answers = questionAnswers.entries.toList();
    for (var index = 0; index < answers.length; index++) {
      parameters["questions_answers[$index][question_id]"] = answers[index].key;
      parameters["questions_answers[$index][answer]"] = answers[index].value;
    }
    return parameters;
  }
}
