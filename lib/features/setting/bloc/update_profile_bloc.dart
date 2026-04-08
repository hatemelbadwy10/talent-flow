import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import '../repo/update_profile_repo.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final SharedPreferences prefs;
  final UpdateProfileRepo repo;

  UpdateProfileBloc({required this.prefs, required this.repo})
      : super(const UpdateProfileState()) {
    // --- Events ---
    on<LoadUserData>(_onLoadUserData);
    on<UpdateFirstName>(
        (e, emit) => emit(state.copyWith(firstName: e.firstName)));
    on<UpdateLastName>((e, emit) => emit(state.copyWith(lastName: e.lastName)));
    on<UpdateEmail>((e, emit) => emit(state.copyWith(email: e.email)));
    on<UpdatePhone>((e, emit) => emit(state.copyWith(phone: e.phone)));
    on<UpdateCountry>(_onUpdateCountry);
    on<UpdateCity>(
      (e, emit) => emit(
        state.copyWith(
          cityId: e.cityId,
          cityName: e.cityName,
        ),
      ),
    );
    on<UpdateGender>((e, emit) => emit(state.copyWith(gender: e.gender)));
    on<UpdateDateOfBirth>(
      (e, emit) => emit(state.copyWith(dateOfBirth: e.dateOfBirth)),
    );
    on<UpdateSpecialization>((e, emit) => emit(
        state.copyWith(specializationId: e.id, specializationName: e.name)));
    on<UpdateJobTitle>((e, emit) =>
        emit(state.copyWith(jobTitleId: e.id, jobTitleName: e.name)));
    on<UpdateBio>((e, emit) => emit(state.copyWith(bio: e.bio)));
    on<UpdateNewPassword>(
        (e, emit) => emit(state.copyWith(newPassword: e.password)));
    on<UpdateConfirmPassword>(
        (e, emit) => emit(state.copyWith(newPasswordConfirmation: e.password)));
    on<UpdateSkills>((e, emit) =>
        emit(state.copyWith(skills: e.skillIds, selectedSkills: e.skillNames)));
    on<UpdateImage>((e, emit) => emit(state.copyWith(image: e.image)));
    on<ClearError>((e, emit) => emit(state.copyWith(errorMessage: null)));
    on<SubmitProfile>(_onSubmitProfile);
  }

  Future<void> _onLoadUserData(
      LoadUserData event, Emitter<UpdateProfileState> emit) async {
    final raw = prefs.getString(AppStorageKey.userData);
    if (raw != null) {
      log('raw: $raw');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      log("state data: $data");
      List<int> parseSkills(dynamic skillsData) {
        if (skillsData == null) return [];

        if (skillsData is List) {
          // case: already a list (could be int or string numbers)
          return skillsData
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .toList();
        }

        if (skillsData is String) {
          // case: string like "1,2,3"
          return skillsData
              .split(',')
              .map((e) => int.tryParse(e.trim()) ?? 0)
              .toList();
        }

        return [];
      }

      emit(
        state.copyWith(
          firstName: data['first_name'] ?? '',
          lastName: data['last_name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          countryId: data['country_id']?.toString(),
          countryName: data['country']?.toString(),
          cityId: data['city_id']?.toString(),
          cityName: data['city']?.toString(),
          gender: data['gender']?.toString(),
          dateOfBirth: data['date_of_birth']?.toString(),
          specializationId: data['specialization_id'],
          specializationName: data['specialization'],
          jobTitleId: data['job_title_id'],
          jobTitleName: data['job_title'],
          bio: data['bio'],
          skills: parseSkills(data['skills']),
          selectedSkills: List<String>.from(data['skillsNames'] ?? []),
        ),
      );

      log("state from prefs: ${state.firstName}");
      log("state from prefs: ${state.email}");
      log("state from prefs: ${state.skills}");
      log("state from prefs: ${state.specializationName}");
      log("state from prefs: ${state.specializationId}");
      log("state from prefs: ${state.image}");
      log("state from prefs: ${state.bio}");
    }
  }

  void _onUpdateCountry(
    UpdateCountry event,
    Emitter<UpdateProfileState> emit,
  ) {
    emit(
      state.copyWith(
        countryId: event.countryId,
        countryName: event.countryName,
        cityId: '',
        cityName: '',
      ),
    );
  }

  Future<void> _onSubmitProfile(
      SubmitProfile event, Emitter<UpdateProfileState> emit) async {
    emit(state.copyWith(
        isSubmitting: true, errorMessage: null, successMessage: null));

    final result = await repo.updateProfile(
      firstName: state.firstName ?? '',
      lastName: state.lastName ?? '',
      email: state.email ?? '',
      phone: state.phone ?? '',
      countryId: state.countryId,
      cityId: state.cityId,
      gender: state.gender,
      dateOfBirth: state.dateOfBirth,
      specializationId: state.specializationId ?? 0,
      jopTitleId: state.jobTitleId ?? 0,
      bio: state.bio,
      newPassword: state.newPassword,
      newPasswordConfirmation: state.newPasswordConfirmation,
      skills: state.skills,
      image: state.image,
    );

    // Handle result using await for proper async handling
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.error,
        ));
      },
      (response) async {
        String successMessage = 'تم التحديث بنجاح'; // Default message

        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;

            // Extract success message
            if (responseData.containsKey('message')) {
              successMessage =
                  responseData['message'] as String? ?? successMessage;
            }

            // Extract and save updated user payload
            if (responseData.containsKey('payload')) {
              final payload = responseData['payload'] as Map<String, dynamic>;

              // Save updated user data to SharedPreferences
              await prefs.setString(
                  AppStorageKey.userData, jsonEncode(payload));

              log('Updated user data saved to SharedPreferences');
              log('Payload: $payload');

              // Parse skills from response
              List<int> parseSkillsFromResponse(dynamic skillsData) {
                if (skillsData == null) return [];
                if (skillsData is List) {
                  return skillsData
                      .map((e) => int.tryParse(e.toString()) ?? 0)
                      .toList();
                }
                if (skillsData is String) {
                  return skillsData
                      .split(',')
                      .map((e) => int.tryParse(e.trim()) ?? 0)
                      .toList();
                }
                return [];
              }

              // Update state with new data from response
              emit(state.copyWith(
                isSubmitting: false,
                isSubmitted: true,
                successMessage: successMessage,
                firstName: payload['first_name'] as String? ?? state.firstName,
                lastName: payload['last_name'] as String? ?? state.lastName,
                email: payload['email'] as String? ?? state.email,
                phone: payload['phone'] as String? ?? state.phone,
                specializationId: payload['specialization_id'] as int? ??
                    state.specializationId,
                specializationName: payload['specialization'] as String? ??
                    state.specializationName,
                jobTitleId: payload['job_title_id'] as int? ?? state.jobTitleId,
                jobTitleName:
                    payload['job_title'] as String? ?? state.jobTitleName,
                bio: payload['bio'] as String? ?? state.bio,
                countryId: payload['country_id']?.toString(),
                countryName: payload['country'] as String?,
                cityId: payload['city_id']?.toString(),
                cityName: payload['city'] as String?,
                gender: payload['gender'] as String?,
                dateOfBirth: payload['date_of_birth'] as String?,
                skills: parseSkillsFromResponse(payload['skills']),
                selectedSkills: payload['skillsNames'] != null
                    ? List<String>.from(payload['skillsNames'] as List)
                    : state.selectedSkills,
              ));
              return;
            }
          }
        } catch (e) {
          log('Error processing response: $e');
        }

        // Fallback: emit success with default message
        emit(state.copyWith(
          isSubmitting: false,
          isSubmitted: true,
          successMessage: successMessage,
        ));
      },
    );
  }
}
