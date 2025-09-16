import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/data/api/end_points.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/error/failures.dart';

class HomeRepo extends BaseRepo {
  HomeRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getHome() async {
    try {
      final response = await dioClient.get(uri: EndPoints.home);
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) { // Catch any other general errors
      return Left(ServerFailure(e.toString()));
    }
  }
  Future<Either<ServerFailure, Response>> getCategories() async {
    try{
      final response = await dioClient.get(uri: EndPoints.categories);
      return Right(response); // If successful, wrap the response in a Right
    } on DioException catch (e) { // Catch Dio-specific errors
      return Left(ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) { // Catch any other general errors
      return Left(ServerFailure(e.toString()));
    }
  }
  Future<Either<ServerFailure, Response>> getFreelancers({int? categoryId}) async {
    try {
      final uri = categoryId != null
          ? "${EndPoints.subCategories}$categoryId" // api/categories/{id}
          : EndPoints.freelancers; // الحالة العادية

      final response = await dioClient.get(uri: uri);
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

Future<Either<ServerFailure, Response>> getFreelancerProfile(int id) async {
  try {
    final response = await dioClient.get(uri: "${EndPoints.freelancerDetails}$id");
    return Right(response);
  } on DioException catch (e) {
    return Left(ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
}