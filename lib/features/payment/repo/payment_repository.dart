import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/model.dart';

abstract interface class PaymentRepository {
  Future<Either<ServerFailure, List<PaymentModel>>> getPaymentMethods();

  Future<Either<ServerFailure, String>> requestContractPayment({
    required String customerNumber,
    required String paymentCode,
    required String paymentAmount,
  });

  Future<Either<ServerFailure, String>> confirmContractPayment({
    required String customerNumber,
    required String paymentCode,
    required String paymentAmount,
    required String paymentOtp,
    required int contractId,
    required String startDate,
  });
}
