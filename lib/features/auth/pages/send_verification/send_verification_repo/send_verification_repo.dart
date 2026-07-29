import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';
import '../model/send_verification_result.dart';
import 'send_verification_repository.dart';

class SendVerificationRepo extends BaseRepo
    implements SendVerificationRepository {
  SendVerificationRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, SendVerificationResult>> sendVerification(
    String identifier,
  ) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.forgetPassword,
        data: FormData.fromMap({'identifier': identifier}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return right(
          SendVerificationResult(message: _messageFrom(response.data)),
        );
      }
      return left(ServerFailure(_messageFrom(response.data)));
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
