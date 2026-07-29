import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import '../repo/profile_repository.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final SharedPreferences _prefs;
  final ProfileRepository _repository;

  UpdateProfileBloc({
    required SharedPreferences prefs,
    required ProfileRepository repository,
  })  : _prefs = prefs,
        _repository = repository,
        super(const UpdateProfileState()) {
    // --- Events ---
    on<LoadUserData>(_onLoadUserData);
    on<UpdateFirstName>(
        (e, emit) => emit(state.copyWith(firstName: e.firstName)));
    on<UpdateLastName>((e, emit) => emit(state.copyWith(lastName: e.lastName)));
    on<UpdateEmail>((e, emit) => emit(state.copyWith(email: e.email)));
    on<UpdatePhone>(_onUpdatePhone);
    on<MarkPhoneVerified>(_onMarkPhoneVerified);
    on<PhoneVerificationRequested>(_onPhoneVerificationRequested);
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
    on<ClearError>(
      (e, emit) => emit(
        state.copyWith(
          clearErrorMessage: true,
        ),
      ),
    );
    on<SubmitProfile>(_onSubmitProfile);
  }

  Future<void> _onLoadUserData(
      LoadUserData event, Emitter<UpdateProfileState> emit) async {
    final raw = _prefs.getString(AppStorageKey.userData);
    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
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
          verifiedPhone:
              (data['phone_verified_at']?.toString().isNotEmpty ?? false)
                  ? data['phone']?.toString()
                  : null,
          phoneVerifiedAt: data['phone_verified_at']?.toString(),
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
    }
  }

  void _onUpdatePhone(
    UpdatePhone event,
    Emitter<UpdateProfileState> emit,
  ) {
    final nextPhone = event.phone.trim();
    final verifiedPhone = state.verifiedPhone?.trim();
    final shouldClearVerification = verifiedPhone != null &&
        verifiedPhone.isNotEmpty &&
        nextPhone != verifiedPhone;

    emit(
      state.copyWith(
        phone: event.phone,
        clearPhoneVerification: shouldClearVerification,
      ),
    );
  }

  void _onMarkPhoneVerified(
    MarkPhoneVerified event,
    Emitter<UpdateProfileState> emit,
  ) {
    emit(
      state.copyWith(
        verifiedPhone: event.phone,
        phoneVerifiedAt: event.verifiedAt,
      ),
    );
  }

  Future<void> _onPhoneVerificationRequested(
    PhoneVerificationRequested event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isSendingPhoneVerification: true,
        phoneVerificationPhone: event.phone,
        clearPhoneVerificationFeedback: true,
      ),
    );
    final result =
        await _repository.sendPhoneVerificationOtp(event.phone.trim());
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSendingPhoneVerification: false,
          phoneVerificationError: failure.error,
        ),
      ),
      (message) => emit(
        state.copyWith(
          isSendingPhoneVerification: false,
          phoneVerificationMessage: message,
          phoneVerificationPhone: event.phone,
        ),
      ),
    );
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
    emit(
      state.copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _repository.updateProfile(
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

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.error,
        ));
      },
      (response) async {
        final payload = response.user;
        emit(
          state.copyWith(
            isSubmitting: false,
            isSubmitted: true,
            successMessage: response.message.trim().isNotEmpty
                ? response.message
                : 'تم التحديث بنجاح',
            updatedUserPayload: payload,
            firstName: payload?['first_name']?.toString() ?? state.firstName,
            lastName: payload?['last_name']?.toString() ?? state.lastName,
            email: payload?['email']?.toString() ?? state.email,
            phone: payload?['phone']?.toString() ?? state.phone,
            verifiedPhone:
                (payload?['phone_verified_at']?.toString().isNotEmpty ?? false)
                    ? (payload?['phone'])?.toString()
                    : state.verifiedPhone,
            phoneVerifiedAt: payload?['phone_verified_at']?.toString() ??
                state.phoneVerifiedAt,
            specializationId:
                _toInt(payload?['specialization_id']) ?? state.specializationId,
            specializationName: payload?['specialization']?.toString() ??
                state.specializationName,
            jobTitleId: _toInt(payload?['job_title_id']) ?? state.jobTitleId,
            jobTitleName:
                payload?['job_title']?.toString() ?? state.jobTitleName,
            bio: payload?['bio']?.toString() ?? state.bio,
            countryId: payload?['country_id']?.toString() ?? state.countryId,
            countryName: payload?['country']?.toString() ?? state.countryName,
            cityId: payload?['city_id']?.toString() ?? state.cityId,
            cityName: payload?['city']?.toString() ?? state.cityName,
            gender: payload?['gender']?.toString() ?? state.gender,
            dateOfBirth:
                payload?['date_of_birth']?.toString() ?? state.dateOfBirth,
            skills: payload == null
                ? state.skills
                : _parseSkills(payload['skills']),
            selectedSkills: payload?['skillsNames'] is List
                ? List<String>.from(payload!['skillsNames'] as List)
                : state.selectedSkills,
          ),
        );
      },
    );
  }

  int? _toInt(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');

  List<int> _parseSkills(Object? value) {
    if (value is List) {
      return value.map((item) => _toInt(item) ?? 0).toList();
    }
    if (value is String) {
      return value.split(',').map((item) => _toInt(item.trim()) ?? 0).toList();
    }
    return const [];
  }
}
