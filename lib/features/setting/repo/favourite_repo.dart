import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';

class FavouriteRepo extends BaseRepo {
  FavouriteRepo({required super.sharedPreferences, required super.dioClient});
  Future<Either<ServerFailure, Response>> getFavouriteProjects() async {
    try {
      const uri = "${EndPoints.projects}?favourite"; // ثابت لأن لا params إضافية
      final response = await dioClient.get(uri: uri);
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

}