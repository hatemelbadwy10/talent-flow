import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/dio/dio_client.dart';
import '../model/account_statement_request_model.dart';

class AccountStatementService {
  AccountStatementService({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<Response> getAccountStatementIndex(
    AccountStatementIndexRequestModel request,
  ) {
    return _dioClient.get(
      uri: EndPoints.accountStatements,
      queryParameters: request.toQueryParameters(),
    );
  }

  Future<Response> getAccountStatementShow(
    AccountStatementShowRequestModel request,
  ) {
    return _dioClient.get(uri: EndPoints.accountStatementDetails(request.id));
  }
}
