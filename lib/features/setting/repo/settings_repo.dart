import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/model/help_model.dart';
import 'package:talent_flow/features/setting/model/identity_verification_request.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';

class SettingsRepo extends BaseRepo {
  SettingsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> help(HelpModel model) async {
    try {
      final response = await dioClient.post(
          uri: EndPoints.help, queryParameters: model.toJson());
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> logout() async {
    try {
      final response = await dioClient.post(uri: EndPoints.logout);
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> submitIdentityVerification(
    IdentityVerificationRequest request,
  ) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.identityVerification,
        data: FormData.fromMap({
          'country_id': request.countryId,
          'first_name_ar': request.firstNameAr,
          'last_name_ar': request.lastNameAr,
          'first_name_en': request.firstNameEn,
          'last_name_en': request.lastNameEn,
          'date_of_birth': request.dateOfBirth,
          'id_card_front_face': await MultipartFile.fromFile(
            request.idCardFrontFace.path,
            filename: _fileName(request.idCardFrontFace),
          ),
          'id_card_back_face': await MultipartFile.fromFile(
            request.idCardBackFace.path,
            filename: _fileName(request.idCardBackFace),
          ),
          'selfie_with_id_card': await MultipartFile.fromFile(
            request.selfieWithIdCard.path,
            filename: _fileName(request.selfieWithIdCard),
          ),
        }),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String _fileName(File file) => file.path.split(Platform.pathSeparator).last;
}
