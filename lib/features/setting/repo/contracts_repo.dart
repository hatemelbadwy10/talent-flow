import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../model/create_contract_request_model.dart';
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

  Future<Either<ServerFailure, Response>> approveContract(
      int contractId) async {
    try {
      final response = await dioClient.get(
        uri: EndPoints.contractApprove(contractId),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> rejectContract({
    required int contractId,
    required String reason,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.contractReject(contractId),
        data: FormData.fromMap({'reason': reason}),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> markWorkCompleted(
    int contractId,
  ) async {
    try {
      final response = await dioClient.get(
        uri: EndPoints.contractComplete(contractId),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> rejectWorkWithNotes({
    required int contractId,
    required String reason,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.contractRejectWork(contractId),
        data: FormData.fromMap({'reason': reason}),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> submitComplaint({
    required int contractId,
    required String content,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.contractComplain(contractId),
        data: FormData.fromMap({'content': content}),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> closeContractAndReview({
    required int contractId,
    required String comment,
    required String rating,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.contractClose(contractId),
        data: FormData.fromMap({
          'comment': comment,
          'rating': rating,
        }),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> reviewEntrepreneur({
    required int contractId,
    required String comment,
    required String rating,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.contractReview(contractId),
        data: FormData.fromMap({
          'comment': comment,
          'rating': rating,
        }),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> getCreateContractPageInfo(
    int projectId,
  ) async {
    try {
      final response = await dioClient.get(
        uri: EndPoints.contractCreatePageInfo(projectId),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> createContract(
    CreateContractRequestModel request,
  ) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.contracts,
        data: await request.toFormData(),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> updateContract({
    required int contractId,
    required CreateContractRequestModel request,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.contractUpdate(contractId),
        data: await request.toFormData(),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
