import 'package:dartz/dartz.dart';

import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/bank_accounts_request_model.dart';
import '../model/bank_accounts_response_model.dart';
import 'bank_accounts_service.dart';

class BankAccountsRepo extends BaseRepo {
  BankAccountsRepo({
    required super.sharedPreferences,
    required super.dioClient,
  }) : _service = BankAccountsService(dioClient: dioClient);

  final BankAccountsService _service;

  Future<Either<ServerFailure, BankAccountsResponseModel>>
      getBankAccounts() async {
    try {
      final response = await _service.getBankAccounts();
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(BankAccountsResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          BankAccountsResponseModel.fromJson(Map<String, dynamic>.from(body)),
        );
      }

      if (body is List) {
        return Right(BankAccountsResponseModel.fromJson({'payload': body}));
      }

      return const Right(BankAccountsResponseModel(items: []));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, BankOptionsResponseModel>>
      getBanksOptions() async {
    try {
      final response = await _service.getBanksOptions();
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(BankOptionsResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          BankOptionsResponseModel.fromJson(Map<String, dynamic>.from(body)),
        );
      }

      if (body is List) {
        return Right(BankOptionsResponseModel.fromJson({'payload': body}));
      }

      return const Right(BankOptionsResponseModel(options: []));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      addBankAccount({
    required BankAccountUpsertRequestModel request,
  }) async {
    try {
      final response = await _service.addBankAccount(request);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(BankAccountMutationResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          BankAccountMutationResponseModel.fromJson(
            Map<String, dynamic>.from(body),
          ),
        );
      }

      return const Right(BankAccountMutationResponseModel());
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      updateBankAccount({
    required BankAccountUpsertRequestModel request,
  }) async {
    try {
      final response = await _service.updateBankAccount(request);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(BankAccountMutationResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          BankAccountMutationResponseModel.fromJson(
            Map<String, dynamic>.from(body),
          ),
        );
      }

      return const Right(BankAccountMutationResponseModel());
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      deleteBankAccount({
    required int id,
  }) async {
    try {
      final response = await _service.deleteBankAccount(id);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(BankAccountMutationResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          BankAccountMutationResponseModel.fromJson(
            Map<String, dynamic>.from(body),
          ),
        );
      }

      return const Right(BankAccountMutationResponseModel());
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
