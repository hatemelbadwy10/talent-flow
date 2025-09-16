import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class ProjectsRepo extends BaseRepo {
  ProjectsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getProjects(
      {String? status, int? categoryId}) async {
    try {
      final uri = categoryId != null
          ? "${EndPoints.subCategories}$categoryId"
          : "${EndPoints.projects}/my-projects?status=$status";
      final response = await dioClient.get(uri: uri);
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> getSingleProject(int id) async {
    try {
      final response = await dioClient.get(
        uri: "${EndPoints.singleProject}$id", // correct interpolation
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
