import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/model.dart';
import 'payment_repository.dart';

class PaymentRepo extends BaseRepo implements PaymentRepository {
  PaymentRepo({required super.sharedPreferences, required super.dioClient});

  @override
  Future<Either<ServerFailure, List<PaymentModel>>> getPaymentMethods() async {
    try {
      final response = await dioClient.get(uri: EndPoints.paymentMethods);
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = data['payload'];
      if (payload is! List) {
        return left(ServerFailure('Payment methods payload is invalid'));
      }
      return right(
        payload
            .whereType<Map>()
            .map((item) => PaymentModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> requestContractPayment({
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
      return right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> confirmContractPayment({
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
      return right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String _messageFrom(Object? data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }
}
