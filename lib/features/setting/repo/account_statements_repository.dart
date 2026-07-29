import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/account_statement_request_model.dart';
import '../model/account_statement_response_model.dart';

abstract interface class AccountStatementsRepository {
  Future<Either<ServerFailure, AccountStatementIndexResponseModel>>
      getAccountStatementIndex({
    AccountStatementIndexRequestModel request,
  });

  Future<Either<ServerFailure, AccountStatementShowResponseModel>>
      getAccountStatementShow({
    required AccountStatementShowRequestModel request,
  });
}
