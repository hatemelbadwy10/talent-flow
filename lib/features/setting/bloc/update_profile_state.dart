import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../main_models/user_model.dart';

class UpdateProfileState extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? verifiedPhone;
  final String? phoneVerifiedAt;
  final int? specializationId;
  final String? specializationName;
  final int? jobTitleId;
  final String? jobTitleName;
  final String? bio;
  final String? newPassword;
  final String? newPasswordConfirmation;
  final List<int> skills;
  final List<String>? selectedSkills; // For display in UI
  final File? image;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;
  final String? successMessage;
  final String? countryId;
  final String? countryName;
  final String? cityId;
  final String? cityName;
  final String? gender;
  final String? dateOfBirth;
  final String? professionalTitle;
  final bool isSendingPhoneVerification;
  final String? phoneVerificationMessage;
  final String? phoneVerificationError;
  final String? phoneVerificationPhone;
  final UserModel? updatedUser;

  const UpdateProfileState({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.verifiedPhone,
    this.phoneVerifiedAt,
    this.specializationId,
    this.specializationName,
    this.jobTitleId,
    this.jobTitleName,
    this.bio,
    this.newPassword,
    this.newPasswordConfirmation,
    this.skills = const [],
    this.selectedSkills,
    this.image,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
    this.successMessage,
    this.countryId,
    this.countryName,
    this.cityId,
    this.cityName,
    this.gender,
    this.dateOfBirth,
    this.professionalTitle,
    this.isSendingPhoneVerification = false,
    this.phoneVerificationMessage,
    this.phoneVerificationError,
    this.phoneVerificationPhone,
    this.updatedUser,
  });

  UpdateProfileState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? verifiedPhone,
    String? phoneVerifiedAt,
    int? specializationId,
    String? specializationName,
    int? jobTitleId,
    String? jobTitleName,
    String? bio,
    String? newPassword,
    String? newPasswordConfirmation,
    List<int>? skills,
    List<String>? selectedSkills,
    File? image,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    String? successMessage,
    String? countryId,
    String? countryName,
    String? cityId,
    String? cityName,
    String? gender,
    String? dateOfBirth,
    String? professionalTitle,
    bool clearPhoneVerification = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool? isSendingPhoneVerification,
    String? phoneVerificationMessage,
    String? phoneVerificationError,
    String? phoneVerificationPhone,
    bool clearPhoneVerificationFeedback = false,
    UserModel? updatedUser,
  }) {
    return UpdateProfileState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      verifiedPhone:
          clearPhoneVerification ? null : verifiedPhone ?? this.verifiedPhone,
      phoneVerifiedAt: clearPhoneVerification
          ? null
          : phoneVerifiedAt ?? this.phoneVerifiedAt,
      specializationId: specializationId ?? this.specializationId,
      specializationName: specializationName ?? this.specializationName,
      jobTitleId: jobTitleId ?? this.jobTitleId,
      jobTitleName: jobTitleName ?? this.jobTitleName,
      bio: bio ?? this.bio,
      newPassword: newPassword ?? this.newPassword,
      newPasswordConfirmation:
          newPasswordConfirmation ?? this.newPasswordConfirmation,
      skills: skills ?? this.skills,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      image: image ?? this.image,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      isSendingPhoneVerification:
          isSendingPhoneVerification ?? this.isSendingPhoneVerification,
      phoneVerificationMessage: clearPhoneVerificationFeedback
          ? null
          : phoneVerificationMessage ?? this.phoneVerificationMessage,
      phoneVerificationError: clearPhoneVerificationFeedback
          ? null
          : phoneVerificationError ?? this.phoneVerificationError,
      phoneVerificationPhone:
          phoneVerificationPhone ?? this.phoneVerificationPhone,
      updatedUser: updatedUser ?? this.updatedUser,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        phone,
        verifiedPhone,
        phoneVerifiedAt,
        specializationId,
        specializationName,
        jobTitleId,
        jobTitleName,
        bio,
        newPassword,
        newPasswordConfirmation,
        skills,
        selectedSkills,
        image,
        isSubmitting,
        isSubmitted,
        errorMessage,
        successMessage,
        countryId,
        countryName,
        cityId,
        cityName,
        gender,
        dateOfBirth,
        professionalTitle,
        isSendingPhoneVerification,
        phoneVerificationMessage,
        phoneVerificationError,
        phoneVerificationPhone,
        updatedUser,
      ];
}
