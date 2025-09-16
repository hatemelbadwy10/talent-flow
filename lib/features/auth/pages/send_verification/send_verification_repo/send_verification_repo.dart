import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/main_repos/base_repo.dart';
import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';

class SendVerificationRepo extends BaseRepo{
  SendVerificationRepo({required super.sharedPreferences, required super.dioClient});
  Future<Either<ServerFailure, Response>> sendVerification(data) async {
    try {
      Response response = await dioClient.post(
          uri: EndPoints.forgetPassword, data: FormData.fromMap(data));
      if (response.statusCode == 200||response.statusCode == 201) {
        log("response ${response}");
        return Right(response);
      } else {
        return left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      log('error $error');
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

}