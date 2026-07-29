import 'package:dartz/dartz.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../model/favourite_model.dart';
import 'favourites_repository.dart';

class FavouriteRepo extends BaseRepo implements FavouritesRepository {
  FavouriteRepo({required super.sharedPreferences, required super.dioClient});

  @override
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

  @override
  Future<Either<ServerFailure, String>> toggleProjectFavourite(int id) async {
    try {
      final response = await dioClient.get(uri: EndPoints.projectFavourite(id));
      return right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> toggleFreelancerFavourite(
      int id) async {
    try {
      final response =
          await dioClient.get(uri: EndPoints.freelancerFavourite(id));
      return right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> toggleWorkFavourite(int id) async {
    try {
      final response = await dioClient.get(uri: EndPoints.workFavourite(id));
      return right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String _messageFrom(Object? data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }
}
