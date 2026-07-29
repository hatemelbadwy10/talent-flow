import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/contract_model.dart';
import '../model/create_contract_page_info_model.dart';
import '../model/create_contract_request_model.dart';

abstract interface class ContractsReadRepository {
  Future<Either<ServerFailure, List<ContractModel>>> getContracts();
  Future<Either<ServerFailure, ContractModel>> getContractDetails(int id);
}

abstract interface class ContractsRepository
    implements ContractsReadRepository {
  Future<Either<ServerFailure, String>> approveContract(int contractId);
  Future<Either<ServerFailure, String>> rejectContract({
    required int contractId,
    required String reason,
  });
  Future<Either<ServerFailure, String>> markWorkCompleted(int contractId);
  Future<Either<ServerFailure, String>> rejectWorkWithNotes({
    required int contractId,
    required String reason,
  });
  Future<Either<ServerFailure, String>> submitComplaint({
    required int contractId,
    required String content,
  });
  Future<Either<ServerFailure, String>> closeContractAndReview({
    required int contractId,
    required String comment,
    required String rating,
  });
  Future<Either<ServerFailure, String>> reviewEntrepreneur({
    required int contractId,
    required String comment,
    required String rating,
  });
  Future<Either<ServerFailure, CreateContractPageInfoModel>>
      getCreateContractPageInfo(int projectId);
  Future<Either<ServerFailure, String>> createContract(
    CreateContractRequestModel request,
  );
  Future<Either<ServerFailure, String>> updateContract({
    required int contractId,
    required CreateContractRequestModel request,
  });
}
