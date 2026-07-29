import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/bank_accounts_request_model.dart';
import '../model/bank_accounts_response_model.dart';

abstract interface class BankAccountsRepository {
  Future<Either<ServerFailure, BankAccountsResponseModel>> getBankAccounts();
  Future<Either<ServerFailure, BankOptionsResponseModel>> getBanksOptions();

  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      addBankAccount({
    required BankAccountUpsertRequestModel request,
  });

  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      updateBankAccount({
    required BankAccountUpsertRequestModel request,
  });

  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      deleteBankAccount({
    required int id,
  });
}
