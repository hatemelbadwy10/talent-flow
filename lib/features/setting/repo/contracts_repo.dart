import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../model/create_contract_request_model.dart';
import '../model/contract_model.dart';
import '../../../main_repos/base_repo.dart';
import 'contracts_repository.dart';

class ContractsRepo extends BaseRepo implements ContractsRepository {
  ContractsRepo({required super.sharedPreferences, required super.dioClient});

  @override
  Future<Either<ServerFailure, List<ContractModel>>> getContracts() async {
    try {
      final response = await dioClient.get(uri: EndPoints.contracts);
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = data['payload'];
      if (payload is! List) {
        return left(ServerFailure('Contracts payload is invalid'));
      }
      return right(
        payload
            .whereType<Map>()
            .map((item) => ContractModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, ContractModel>> getContractDetails(
      int id) async {
    try {
      final response = await dioClient.get(uri: EndPoints.contractDetails(id));
      final body = response.data;
      final payload =
          body is Map && body['payload'] != null ? body['payload'] : body;
      if (payload is! Map) {
        return left(ServerFailure('Contract payload is invalid'));
      }
      return right(
        ContractModel.fromJson(Map<String, dynamic>.from(payload)),
      );
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
