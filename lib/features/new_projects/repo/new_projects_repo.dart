import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class NewProjectsRepo extends BaseRepo {
  NewProjectsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getProjects() async {
    try {
      final response = await dioClient.get(uri: EndPoints.projects);
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> addOffer(int id, String offer) async {
    try {
      final response = await dioClient.post(
          uri: EndPoints.addOffer,
          queryParameters: {"project_id": id, "description": offer});
      return Right(response);
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
