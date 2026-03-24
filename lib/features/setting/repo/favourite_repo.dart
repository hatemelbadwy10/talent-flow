import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../model/favourite_model.dart';

class FavouriteRepo extends BaseRepo {
  FavouriteRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, FavouriteResponseModel>> getFavourites() async {
    try {
      const uri = EndPoints.favourites;
      final response = await dioClient.get(uri: uri);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(FavouriteResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          FavouriteResponseModel.fromJson(
            Map<String, dynamic>.from(body),
          ),
        );
      }

      return const Right(
        FavouriteResponseModel(
          payload: FavouritePayloadModel(
            projects: [],
            freelancers: [],
            works: [],
          ),
        ),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> toggleProjectFavourite(int id) async {
    try {
      final response = await dioClient.get(uri: EndPoints.projectFavourite(id));
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> toggleFreelancerFavourite(
      int id) async {
    try {
      final response =
          await dioClient.get(uri: EndPoints.freelancerFavourite(id));
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> toggleWorkFavourite(int id) async {
    try {
      final response = await dioClient.get(uri: EndPoints.workFavourite(id));
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
