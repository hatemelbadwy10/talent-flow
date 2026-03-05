import 'package:dartz/dartz.dart';

import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/account_statement_request_model.dart';
import '../model/account_statement_response_model.dart';
import 'account_statement_service.dart';

class AccountStatementRepo extends BaseRepo {
  AccountStatementRepo({
    required super.sharedPreferences,
    required super.dioClient,
  }) : _service = AccountStatementService(dioClient: dioClient);

  final AccountStatementService _service;

  Future<Either<ServerFailure, AccountStatementIndexResponseModel>>
      getAccountStatementIndex({
    AccountStatementIndexRequestModel request =
        const AccountStatementIndexRequestModel(),
  }) async {
    try {
      final response = await _service.getAccountStatementIndex(request);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(AccountStatementIndexResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          AccountStatementIndexResponseModel.fromJson(
            Map<String, dynamic>.from(body),
          ),
        );
      }

      if (body is List) {
        return Right(
          AccountStatementIndexResponseModel.fromJson({'payload': body}),
        );
      }

      return const Right(AccountStatementIndexResponseModel(items: []));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, AccountStatementShowResponseModel>>
      getAccountStatementShow({
    required AccountStatementShowRequestModel request,
  }) async {
    try {
      final response = await _service.getAccountStatementShow(request);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(AccountStatementShowResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          AccountStatementShowResponseModel.fromJson(
            Map<String, dynamic>.from(body),
          ),
        );
      }

      if (body is List) {
        return Right(
          AccountStatementShowResponseModel.fromJson({'payload': body}),
        );
      }

      return const Right(AccountStatementShowResponseModel());
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
