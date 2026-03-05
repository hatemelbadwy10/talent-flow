import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class ContractsRepo extends BaseRepo {
  ContractsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getContracts() async {
    try {
      final response = await dioClient.get(uri: EndPoints.contracts);
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> getContractDetails(int id) async {
    try {
      final response = await dioClient.get(uri: EndPoints.contractDetails(id));
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
