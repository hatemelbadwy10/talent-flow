import 'dart:io';
import 'package:equatable/equatable.dart';

class UpdateProfileState extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
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


  const UpdateProfileState({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
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
  });

  UpdateProfileState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
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
  }) {
    return UpdateProfileState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
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
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
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
  ];
}
