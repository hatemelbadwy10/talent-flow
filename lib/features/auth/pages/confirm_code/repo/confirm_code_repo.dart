import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';
import '../../../models/auth_response.dart';
import '../model/confirm_code_request.dart';
import '../model/confirm_code_result.dart';
import 'confirm_code_repository.dart';

class ConfirmCodeRepo extends BaseRepo implements ConfirmCodeRepository {
  ConfirmCodeRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, ConfirmCodeResult>> confirm(
    ConfirmCodeRequest request,
  ) async {
    try {
      final response = await dioClient.post(
        uri: _endpointFor(request.flow),
        data: request.flow == ConfirmationFlow.phoneVerification
            ? FormData.fromMap(request.toJson())
            : request.toJson(),
      );
      if (response.statusCode != 200) {
        return left(ServerFailure(_messageFrom(response.data)));
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      AuthResponse? authResponse;
      if (request.flow == ConfirmationFlow.registration) {
        authResponse = AuthResponse.fromJson(data);
      }
      return right(ConfirmCodeResult(
        message: _messageFrom(data),
        authResponse: authResponse,
      ));
    } on FormatException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String _endpointFor(ConfirmationFlow flow) {
    if (flow == ConfirmationFlow.registration ||
        flow == ConfirmationFlow.loginActivation) {
      return EndPoints.verifyRegister;
    }
    return EndPoints.verifyOtp;
  }

  String _messageFrom(Object? data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }
}
