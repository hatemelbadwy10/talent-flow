import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/data/api/end_points.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../model/profile_update_result.dart';
import '../../../main_models/user_model.dart';
import 'profile_repository.dart';

class UpdateProfileRepo extends BaseRepo implements ProfileRepository {
  UpdateProfileRepo(
      {required super.sharedPreferences, required super.dioClient});

  @override
  Future<Either<ServerFailure, String>> sendPhoneVerificationOtp(
    String phone,
  ) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.verifyPhone,
        data: FormData.fromMap({
          'phone': phone,
        }),
      );
      return Right(_messageFrom(response.data));
    } catch (error) {
      log('sendPhoneVerificationOtp error $error');
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, ProfileUpdateResult>> updateProfile(
      {required String firstName,
      required String email,
      required String lastName,
      required String phone,
      String? countryId,
      String? cityId,
      String? gender,
      String? dateOfBirth,
      required int specializationId,
      required int jopTitleId,
      String? bio,
      String? newPassword,
      String? newPasswordConfirmation,
      required List<int> skills,
      File? image}) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('first_name', firstName),
        MapEntry('email', email),
        MapEntry('last_name', lastName),
        MapEntry('phone', phone),
        MapEntry('specialization_id', '$specializationId'),
        MapEntry('job_title_id', '$jopTitleId'),
      ]);

      if ((countryId ?? '').isNotEmpty) {
        formData.fields.add(MapEntry('country_id', countryId!));
      }
      if ((cityId ?? '').isNotEmpty) {
        formData.fields.add(MapEntry('city_id', cityId!));
      }
      if ((gender ?? '').isNotEmpty) {
        formData.fields.add(MapEntry('gender', gender!));
      }
      if ((dateOfBirth ?? '').isNotEmpty) {
        formData.fields.add(MapEntry('date_of_birth', dateOfBirth!));
      }
      if ((bio ?? '').isNotEmpty) {
        formData.fields.add(MapEntry('bio', bio!));
      }
      if ((newPassword ?? '').isNotEmpty) {
        formData.fields.add(MapEntry('new_password', newPassword!));
      }
      if ((newPasswordConfirmation ?? '').isNotEmpty) {
        formData.fields.add(
          MapEntry('new_password_confirmation', newPasswordConfirmation!),
        );
      }

      for (var i = 0; i < skills.length; i++) {
        formData.fields.add(MapEntry('skills[$i]', '${skills[i]}'));
      }

      if (image != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(image.path)),
        );
      }

      final response = await dioClient.post(
        data: formData,
        uri: EndPoints.editProfile,
      );
      final data = response.data;
      final responseMap =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final payload = responseMap['payload'];
      return Right(
        ProfileUpdateResult(
          message: responseMap['message']?.toString() ?? '',
          user: payload is Map
              ? UserModel.fromJson(Map<String, dynamic>.from(payload))
              : null,
        ),
      );
    } catch (error) {
      log('error $error');
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
