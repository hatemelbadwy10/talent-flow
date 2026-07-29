import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/model/help_model.dart';
import 'package:talent_flow/features/setting/model/identity_verification_details.dart';
import 'package:talent_flow/features/setting/model/identity_verification_request.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import 'settings_repository.dart';
import 'identity_verification_repository.dart';

class SettingsRepo extends BaseRepo
    implements SettingsRepository, IdentityVerificationRepository {
  SettingsRepo({required super.sharedPreferences, required super.dioClient});

  @override
  Future<Either<ServerFailure, String>> help(HelpModel model) async {
    try {
      final response = await dioClient.post(
          uri: EndPoints.help, queryParameters: model.toJson());
      return Right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> logout() async {
    try {
      final response = await dioClient.post(uri: EndPoints.logout);
      return Right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> deleteAccount() async {
    try {
      final response = await dioClient.delete(uri: EndPoints.deleteAccount);
      return Right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> submitIdentityVerification(
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
      return Right(_messageFrom(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, IdentityVerificationDetails?>>
      getIdentityVerification() async {
    try {
      final response = await dioClient.get(uri: EndPoints.identityVerification);
      final payload = response.data is Map<String, dynamic>
          ? response.data['payload']
          : null;

      if (payload is Map<String, dynamic>) {
        return Right(IdentityVerificationDetails.fromJson(payload));
      }

      return const Right(null);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String _fileName(File file) => file.path.split(Platform.pathSeparator).last;

  String _messageFrom(Object? data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }
}
