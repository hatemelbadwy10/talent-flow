import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/update_profile_bloc.dart';
import 'package:talent_flow/features/setting/bloc/update_profile_event.dart';
import 'package:talent_flow/features/setting/model/profile_update_result.dart';
import 'package:talent_flow/features/setting/repo/profile_repository.dart';
import 'package:talent_flow/main_models/user_model.dart';

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test('phone verification request is forwarded through the bloc', () async {
    final repository = _FakeProfileRepository();
    final bloc = UpdateProfileBloc(
      prefs: preferences,
      repository: repository,
    )..add(const PhoneVerificationRequested('01000000000'));

    final state = await bloc.stream.firstWhere(
      (state) => state.phoneVerificationMessage != null,
    );
    expect(repository.verificationPhone, '01000000000');
    expect(state.phoneVerificationMessage, 'Code sent');
    expect(state.isSendingPhoneVerification, isFalse);
    await bloc.close();
  });

  test('profile update emits parsed user payload for presentation persistence',
      () async {
    final repository = _FakeProfileRepository();
    final bloc = UpdateProfileBloc(
      prefs: preferences,
      repository: repository,
    )..add(const UpdateFirstName('Hatem'));
    await bloc.stream.firstWhere((state) => state.firstName == 'Hatem');
    bloc.add(SubmitProfile());

    final state = await bloc.stream.firstWhere((state) => state.isSubmitted);
    expect(state.updatedUser, same(repository.user));
    expect(state.firstName, 'Hatem Updated');
    expect(state.successMessage, 'Profile saved');
    await bloc.close();
  });
}

class _FakeProfileRepository implements ProfileRepository {
  String? verificationPhone;
  final user = UserModel(
    firstName: 'Hatem Updated',
    skills: const [1, 2],
  );

  @override
  Future<Either<ServerFailure, String>> sendPhoneVerificationOtp(
    String phone,
  ) async {
    verificationPhone = phone;
    return right('Code sent');
  }

  @override
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
  }) async {
    return right(ProfileUpdateResult(message: 'Profile saved', user: user));
  }
}
