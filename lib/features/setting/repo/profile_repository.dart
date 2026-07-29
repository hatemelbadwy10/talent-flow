import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/profile_update_result.dart';

abstract interface class ProfileRepository {
  Future<Either<ServerFailure, String>> sendPhoneVerificationOtp(String phone);

  Future<Either<ServerFailure, ProfileUpdateResult>> updateProfile({
    required String firstName,
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
    File? image,
  });
}
