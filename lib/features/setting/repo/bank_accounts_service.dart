import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/dio/dio_client.dart';
import '../model/bank_accounts_request_model.dart';

class BankAccountsService {
  BankAccountsService({required DioClient dioClient}) : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<Response> getBankAccounts() {
    return _dioClient.get(uri: EndPoints.bankAccounts);
  }

  Future<Response> getBanksOptions() {
    return _dioClient.get(uri: EndPoints.banksOptions);
  }

  Future<Response> addBankAccount(BankAccountUpsertRequestModel request) {
    return _dioClient.post(
      uri: EndPoints.bankAccounts,
      queryParameters: request.toQueryParameters(),
    );
  }

  Future<Response> updateBankAccount(BankAccountUpsertRequestModel request) {
    return _dioClient.post(
      uri: request.id != null
          ? EndPoints.bankAccountById(request.id!)
          : EndPoints.bankAccountsUpdate,
      queryParameters: request.toQueryParameters(),
    );
  }

  Future<Response> deleteBankAccount(int id) {
    return _dioClient.delete(uri: EndPoints.bankAccountById(id));
  }
}
