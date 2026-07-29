import 'package:dartz/dartz.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/my_projects_model.dart';
import '../model/single_project_model.dart';
import 'projects_repository.dart';

class ProjectsRepo extends BaseRepo implements ProjectsRepository {
  ProjectsRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, List<MyProjectsModel>>> getProjectList({
    String? status,
    int? categoryId,
  }) async {
    try {
      final normalizedStatus = status?.trim();
      final hasStatusFilter = normalizedStatus != null &&
          normalizedStatus.isNotEmpty &&
          normalizedStatus != 'all';
      final response = await dioClient.get(
        uri: categoryId == null
            ? '${EndPoints.projects}/my-projects'
            : '${EndPoints.subCategories}$categoryId',
        queryParameters: categoryId == null && hasStatusFilter
            ? {'status': normalizedStatus}
            : null,
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final rootPayload = data['payload'];
      final payload = categoryId == null
          ? rootPayload
          : rootPayload is Map
              ? rootPayload['items']
              : null;
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
  Future<Either<ServerFailure, SingleProjectModel>> getProjectDetails(
    int id,
  ) async {
    try {
      final response = await dioClient.get(
        uri: '${EndPoints.singleProject}$id',
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = data['payload'];
      if (payload is! Map) {
        return left(ServerFailure('Project details payload is invalid'));
      }
      return right(
        SingleProjectModel.fromJson(Map<String, dynamic>.from(payload)),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
