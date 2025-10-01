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
    on<UpdateFirstName>((e, emit) => emit(state.copyWith(firstName: e.firstName)));
    on<UpdateLastName>((e, emit) => emit(state.copyWith(lastName: e.lastName)));
    on<UpdateEmail>((e, emit) => emit(state.copyWith(email: e.email)));
    on<UpdatePhone>((e, emit) => emit(state.copyWith(phone: e.phone)));
    on<UpdateSpecialization>(
            (e, emit) => emit(state.copyWith(specializationId: e.id, specializationName: e.name)));
    on<UpdateJobTitle>(
            (e, emit) => emit(state.copyWith(jobTitleId: e.id, jobTitleName: e.name)));
    on<UpdateBio>((e, emit) => emit(state.copyWith(bio: e.bio)));
    on<UpdateNewPassword>((e, emit) => emit(state.copyWith(newPassword: e.password)));
    on<UpdateConfirmPassword>((e, emit) =>
        emit(state.copyWith(newPasswordConfirmation: e.password)));
    on<UpdateSkills>((e, emit) => emit(state.copyWith(skills: e.skillIds, selectedSkills: e.skillNames)));
    on<UpdateImage>((e, emit) => emit(state.copyWith(image: e.image)));
    on<SubmitProfile>(_onSubmitProfile);
  }

  Future<void> _onLoadUserData(
      LoadUserData event, Emitter<UpdateProfileState> emit) async {
    final raw = prefs.getString(AppStorageKey.userData);
    if (raw != null) {
      log('raw: $raw');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      log("state data: $data");
      List<int> _parseSkills(dynamic skillsData) {
        if (skillsData == null) return [];

        if (skillsData is List) {
          // case: already a list (could be int or string numbers)
          return skillsData.map((e) => int.tryParse(e.toString()) ?? 0).toList();
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
          specializationId: data['specialization_id'],
          specializationName: data['specialization'],
          jobTitleId: data['job_title_id'],
          jobTitleName: data['job_title'],
          bio: data['bio'],
          skills: _parseSkills(data['skills']),
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

  Future<void> _onSubmitProfile(
      SubmitProfile event, Emitter<UpdateProfileState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final result = await repo.updateProfile(
      firstName: state.firstName ?? '',
      lastName: state.lastName ?? '',
      email: state.email ?? '',
      phone: state.phone ?? '',
      specializationId: state.specializationId ?? 0,
      jopTitleId: state.jobTitleId ?? 0,
      bio: state.bio,
      newPassword: state.newPassword,
      newPasswordConfirmation: state.newPasswordConfirmation,
      skills: state.skills,
      image: state.image,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.toString()
      )),
          (_) => emit(state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
      )),
    );
  }
}
