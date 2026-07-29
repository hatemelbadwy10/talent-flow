import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../../projects/model/my_projects_model.dart';
import 'new_projects_repository.dart';

class NewProjectsRepo extends BaseRepo implements NewProjectsRepository {
  NewProjectsRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, List<MyProjectsModel>>> getProjectFeed({
    int? specializationId,
    String? sortBy,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (specializationId != null) {
        queryParameters['specialization'] = specializationId;
      }
      if (sortBy?.trim().isNotEmpty == true) {
        queryParameters['sortBy'] = sortBy!.trim();
      }
      if (search?.trim().isNotEmpty == true) {
        queryParameters['search'] = search!.trim();
      }
      final response = await dioClient.get(
        uri: EndPoints.projects,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = data['payload'];
      if (payload is! List) {
        return left(ServerFailure('Projects payload is invalid'));
      }
      return right(
        payload
            .map((item) => MyProjectsModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(growable: false),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> submitOffer({
    required int projectId,
    required String description,
    required List<Map<String, dynamic>> answers,
    int? proposalId,
  }) async {
    try {
      final formData = _offerFormData(
        projectId: projectId,
        description: description,
        answers: answers,
      );
      final response = proposalId == null
          ? await dioClient.post(uri: EndPoints.addOffer, data: formData)
          : await _updateOffer(proposalId, formData);
      return right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> toggleProjectFavorite(
    int projectId,
  ) async {
    try {
      final response = await dioClient.get(
        uri: '${EndPoints.projects}/$projectId/favourite',
      );
      return right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  FormData _offerFormData({
    required int projectId,
    required String description,
    required List<Map<String, dynamic>> answers,
  }) {
    final formData = FormData()
      ..fields.add(MapEntry('project_id', '$projectId'))
      ..fields.add(MapEntry('description', description));
    for (var index = 0; index < answers.length; index++) {
      formData.fields.add(MapEntry(
        'questions_answers[$index][question_id]',
        '${answers[index]['question_id']}',
      ));
      formData.fields.add(MapEntry(
        'questions_answers[$index][answer]',
        answers[index]['answer']?.toString() ?? '',
      ));
    }
    return formData;
  }

  Future<Response<dynamic>> _updateOffer(
    int proposalId,
    FormData formData,
  ) async {
    try {
      return await dioClient.put(
        uri: EndPoints.projectProposal(proposalId),
        data: formData,
      );
    } catch (_) {
      return dioClient.post(
        uri: EndPoints.projectProposal(proposalId),
        data: formData,
      );
    }
  }

  String _messageFrom(Object? data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }
}
