import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class PaymentRepo extends BaseRepo {
  PaymentRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getPayment() async {
    try {
      final response = await dioClient.get(uri: EndPoints.paymentMethods);
      return right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> requestContractPayment({
    required String customerNumber,
    required String paymentCode,
    required String paymentAmount,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.paymentRequest,
        data: FormData.fromMap({
          'payment_CustomerNo': customerNumber,
          'payment_Code': paymentCode,
          'payment_Amount': paymentAmount,
        }),
      );
      return right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> confirmContractPayment({
    required String customerNumber,
    required String paymentCode,
    required String paymentAmount,
    required String paymentOtp,
    required int contractId,
    required String startDate,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.paymentConfirm,
        data: FormData.fromMap({
          'payment_CustomerNo': customerNumber,
          'payment_Code': paymentCode,
          'payment_Amount': paymentAmount,
          'Payment_OTP': paymentOtp,
          'contract_id': contractId,
          'start_date': startDate,
        }),
      );
      return right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String messageFromResponse(
    Response response, {
    String fallback = '',
  }) {
    final data = response.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return fallback;
  }
}
