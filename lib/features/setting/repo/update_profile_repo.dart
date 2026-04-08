import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/data/api/end_points.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';

class UpdateProfileRepo extends BaseRepo {
  UpdateProfileRepo(
      {required super.sharedPreferences, required super.dioClient});
  Future<Either<ServerFailure, Response>> updateProfile(
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
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'email': email,
      'last_name': lastName,
      'phone': phone,
      if ((countryId ?? '').isNotEmpty) 'country_id': countryId,
      if ((cityId ?? '').isNotEmpty) 'city_id': cityId,
      if ((gender ?? '').isNotEmpty) 'gender': gender,
      if ((dateOfBirth ?? '').isNotEmpty) 'date_of_birth': dateOfBirth,
      'specialization_id': specializationId,
      'job_title_id': jopTitleId,
      'bio': bio,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
      'skills': skills,
      "image": image
    };

    if (image != null) {
      data['image'] = await MultipartFile.fromFile(image.path);
    }
    try {
      final response =
          await dioClient.post(data: data, uri: EndPoints.editProfile);
      return Right(response);
    } catch (error) {
      log('error $error');
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
