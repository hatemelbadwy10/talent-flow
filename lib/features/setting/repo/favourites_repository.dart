import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/favourite_model.dart';

abstract interface class FavouritesRepository {
  Future<Either<ServerFailure, FavouriteResponseModel>> getFavourites();
  Future<Either<ServerFailure, String>> toggleProjectFavourite(int id);
  Future<Either<ServerFailure, String>> toggleFreelancerFavourite(int id);
  Future<Either<ServerFailure, String>> toggleWorkFavourite(int id);
}
