import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class PaymentRepo extends BaseRepo {
  PaymentRepo({required super.sharedPreferences, required super.dioClient});
  Future <Either<ServerFailure, Response>>getPayment()async{
    try {
      final response = await dioClient.get(uri: EndPoints.paymentMethods);
      return right(response);
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }
}