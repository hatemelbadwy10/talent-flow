import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/contract_model.dart';

abstract interface class ContractsRepository {
  Future<Either<ServerFailure, List<ContractModel>>> getContracts();
  Future<Either<ServerFailure, ContractModel>> getContractDetails(int id);
}
