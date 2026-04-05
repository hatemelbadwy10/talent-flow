import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();
  @override
  List<Object?> get props => [];
}

// --- Initialization ---
class LoadUserData extends UpdateProfileEvent {} // load from SharedPreferences

class LoadSelections
    extends UpdateProfileEvent {} // load specialization, job titles, skills from API

// --- Field updates ---
class UpdateFirstName extends UpdateProfileEvent {
  final String firstName;
  const UpdateFirstName(this.firstName);

  @override
  List<Object?> get props => [firstName];
}

class UpdateLastName extends UpdateProfileEvent {
  final String lastName;
  const UpdateLastName(this.lastName);

  @override
  List<Object?> get props => [lastName];
}

class UpdateEmail extends UpdateProfileEvent {
  final String email;
  const UpdateEmail(this.email);

  @override
  List<Object?> get props => [email];
}

class UpdatePhone extends UpdateProfileEvent {
  final String phone;
  const UpdatePhone(this.phone);

  @override
  List<Object?> get props => [phone];
}

class UpdateSpecialization extends UpdateProfileEvent {
  final int id;
  final String name;
  const UpdateSpecialization({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class UpdateJobTitle extends UpdateProfileEvent {
  final int id;
  final String name;
  const UpdateJobTitle({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class UpdateBio extends UpdateProfileEvent {
  final String bio;
  const UpdateBio(this.bio);

  @override
  List<Object?> get props => [bio];
}

class UpdateNewPassword extends UpdateProfileEvent {
  final String password;
  const UpdateNewPassword(this.password);

  @override
  List<Object?> get props => [password];
}

class UpdateConfirmPassword extends UpdateProfileEvent {
  final String password;
  const UpdateConfirmPassword(this.password);

  @override
  List<Object?> get props => [password];
}

class UpdateSkills extends UpdateProfileEvent {
  final List<int> skillIds;
  final List<String> skillNames;
  const UpdateSkills({required this.skillIds, required this.skillNames});

  @override
  List<Object?> get props => [skillIds, skillNames];
}

class UpdateImage extends UpdateProfileEvent {
  final File image;
  const UpdateImage(this.image);

  @override
  List<Object?> get props => [image];
}

class UpdateCountry extends UpdateProfileEvent {
  final String countryId;
  final String countryName;
  const UpdateCountry({required this.countryId, required this.countryName});

  @override
  List<Object?> get props => [countryId, countryName];
}

class UpdateCity extends UpdateProfileEvent {
  final String cityId;
  final String cityName;
  const UpdateCity({required this.cityId, required this.cityName});

  @override
  List<Object?> get props => [cityId, cityName];
}

class UpdateGender extends UpdateProfileEvent {
  final String gender;
  const UpdateGender(this.gender);

  @override
  List<Object?> get props => [gender];
}

class UpdateDateOfBirth extends UpdateProfileEvent {
  final String dateOfBirth;
  const UpdateDateOfBirth(this.dateOfBirth);

  @override
  List<Object?> get props => [dateOfBirth];
}

class UpdateProfessionalTitle extends UpdateProfileEvent {
  final String professionalTitle;
  const UpdateProfessionalTitle(this.professionalTitle);

  @override
  List<Object?> get props => [professionalTitle];
}

class ClearError extends UpdateProfileEvent {}

// --- Submit form ---
class SubmitProfile extends UpdateProfileEvent {}
