import 'package:dartz/dartz.dart';
import '../../../data/api/end_points.dart';
import '../../../data/api/response_payload_parser.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/my_projects_model.dart';
import '../model/single_project_model.dart';

class ProjectsRepo extends BaseRepo {
  ProjectsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, List<MyProjectsModel>>> getProjects({
    String? status,
    int? categoryId,
  }) async {
    try {
      if (categoryId != null) {
        final response = await dioClient.get(
          uri: "${EndPoints.subCategories}$categoryId",
        );
        final payload = ResponsePayloadParser.payloadMap(response.data);
        final items = ResponsePayloadParser.list(payload['items']);
        return Right(
          items
              .map((item) =>
                  MyProjectsModel.fromJson(ResponsePayloadParser.map(item)))
              .toList(),
        );
      }

      final normalizedStatus = status?.trim();
      final hasStatusFilter = normalizedStatus != null &&
          normalizedStatus.isNotEmpty &&
          normalizedStatus != "all";

      final response = await dioClient.get(
        uri: "${EndPoints.projects}/my-projects",
        queryParameters: hasStatusFilter ? {"status": normalizedStatus} : null,
      );
      final payload = ResponsePayloadParser.payloadList(response.data);
      return Right(
        payload
            .map((item) =>
                MyProjectsModel.fromJson(ResponsePayloadParser.map(item)))
            .toList(),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, SingleProjectModel>> getSingleProject(
    int id,
  ) async {
    try {
      final response = await dioClient.get(
        uri: "${EndPoints.singleProject}$id",
      );
      final payload = ResponsePayloadParser.payloadMap(response.data);
      return Right(SingleProjectModel.fromJson(payload));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
