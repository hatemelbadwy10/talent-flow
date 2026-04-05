import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/setting/bloc/update_profile_bloc.dart';
import 'package:talent_flow/features/setting/bloc/update_profile_event.dart';
import 'package:talent_flow/features/setting/bloc/update_profile_state.dart';
import 'package:talent_flow/features/setting/widgets/error_drop_down.dart';
import 'package:talent_flow/features/setting/widgets/loading_drop_down.dart';
import 'package:talent_flow/app/core/images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_event.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_state.dart';
import 'package:talent_flow/features/setting/widgets/edit_profile_sections.dart';

import '../../../helpers/pickers/view/image_picker_helper.dart';
import '../repo/update_profile_repo.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              SelectionOptionBloc(sl())..add(const SelectionOptionsRequested()),
        ),
        BlocProvider(
          create: (context) => UpdateProfileBloc(
            prefs: sl<SharedPreferences>(),
            repo: sl<UpdateProfileRepo>(),
          )..add(LoadUserData()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          title: Image.asset(
            Images.appLogo,
            height: 35,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  "edit_profile.title".tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: EditProfileForm(
          currentImageUrl:
              sl<SharedPreferences>().getString(AppStorageKey.userImage) ??
                  Images.appLogo,
        ),
      ),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({
    super.key,
    required this.currentImageUrl,
  });

  final String currentImageUrl;

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  Map<String, String> _allAvailableSkills = {};
  Map<String, String> _allAvailableSpecializations = {};
  Map<String, String> _allAvailableJobTitles = {};
  String? _lastShownErrorMessage;
  bool _lastShownSuccessState = false;

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
      listener: (context, state) {
        // Only show success snackbar once
        if (state.isSubmitted && !_lastShownSuccessState) {
          _lastShownSuccessState = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage ?? 'تم التحديث بنجاح')),
          );
          Navigator.of(context).pop();
        }

        // Only show error snackbar if it's a new error message
        if (state.errorMessage != null &&
            state.errorMessage != _lastShownErrorMessage) {
          _lastShownErrorMessage = state.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        // Reset error message tracker when it's cleared
        if (state.errorMessage == null) {
          _lastShownErrorMessage = null;
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              _buildProfileHeader(context, state),
              const SizedBox(height: 32),
              _buildNameFields(context, state),
              _buildEmailField(context, state),
              _buildPhoneField(context, state),
              _buildCountryField(context, state),
              _buildCityField(context, state),
              _buildGenderField(context, state),
              _buildDateOfBirthField(context, state),
              _buildSpecializationField(context, state),
              _buildJobTitleField(context, state),
              _buildBioField(context, state),
              _buildSkillsField(context, state),
              _buildPasswordFields(context, state),
              const SizedBox(height: 24),
              _buildSaveButton(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UpdateProfileState state) {
    return EditProfileHeaderSection(
      image: state.image,
      imageUrl: widget.currentImageUrl,
      onCameraTap: () {
        ImagePickerHelper.openCamera(onGet: (file) {
          context.read<UpdateProfileBloc>().add(UpdateImage(file));
        });
      },
      onGalleryTap: () {
        ImagePickerHelper.openGallery(onGet: (file) {
          context.read<UpdateProfileBloc>().add(UpdateImage(file));
        });
      },
    );
  }

  Widget _buildNameFields(BuildContext context, UpdateProfileState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: EditProfileFormField(
            label: "edit_profile.first_name".tr(),
            hint: state.firstName ?? "edit_profile.first_name_hint".tr(),
            value: state.firstName ?? '',
            onChanged: (value) =>
                context.read<UpdateProfileBloc>().add(UpdateFirstName(value)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: EditProfileFormField(
            label: "edit_profile.last_name".tr(),
            hint: state.lastName ?? "edit_profile.last_name_hint".tr(),
            value: state.lastName ?? '',
            onChanged: (value) =>
                context.read<UpdateProfileBloc>().add(UpdateLastName(value)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, UpdateProfileState state) {
    return EditProfileFormField(
      label: "edit_profile.email".tr(),
      hint: state.email ?? "edit_profile.email_hint".tr(),
      value: state.email ?? '',
      onChanged: (value) =>
          context.read<UpdateProfileBloc>().add(UpdateEmail(value)),
    );
  }

  Widget _buildPhoneField(BuildContext context, UpdateProfileState state) {
    return EditProfileFormField(
      label: "edit_profile.phone".tr(),
      hint: state.phone ?? "edit_profile.phone_hint".tr(),
      value: state.phone ?? '',
      onChanged: (value) =>
          context.read<UpdateProfileBloc>().add(UpdatePhone(value)),
    );
  }

  Widget _buildCountryField(BuildContext context, UpdateProfileState state) {
    return EditProfileFormField(
      label: "edit_profile.country".tr(),
      hint: state.countryName ?? "edit_profile.country_hint".tr(),
      value: state.countryName ?? '',
      readOnly: true,
      onChanged: (value) {},
    );
  }

  Widget _buildCityField(BuildContext context, UpdateProfileState state) {
    return EditProfileFormField(
      label: "edit_profile.city".tr(),
      hint: state.cityName ?? "edit_profile.city_hint".tr(),
      value: state.cityName ?? '',
      readOnly: true,
      onChanged: (value) {},
    );
  }

  Widget _buildGenderField(BuildContext context, UpdateProfileState state) {
    return EditProfileFormField(
      label: "edit_profile.gender".tr(),
      hint: state.gender ?? "edit_profile.gender_hint".tr(),
      value: state.gender ?? '',
      readOnly: true,
      onChanged: (value) {},
    );
  }

  Widget _buildDateOfBirthField(
      BuildContext context, UpdateProfileState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: "edit_profile.date_of_birth".tr(),
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black),
              children: const [
                TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 16))
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: _buildNumberDropdown(
                  value: state.dateOfBirth?.split('/')[2] ?? '1990',
                  label: 'Year',
                  items: List.generate(
                      100, (i) => (DateTime.now().year - i).toString()),
                  onChanged: (value) {
                    // Handle year change
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNumberDropdown(
                  value: state.dateOfBirth?.split('/')[1] ?? '03',
                  label: 'Month',
                  items: List.generate(
                      12, (i) => (i + 1).toString().padLeft(2, '0')),
                  onChanged: (value) {
                    // Handle month change
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNumberDropdown(
                  value: state.dateOfBirth?.split('/')[0] ?? '22',
                  label: 'Day',
                  items: List.generate(
                      31, (i) => (i + 1).toString().padLeft(2, '0')),
                  onChanged: (value) {
                    // Handle day change
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: DropdownButton<String>(
            value: value ?? items.first,
            onChanged: onChanged,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            isExpanded: true,
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildBioField(BuildContext context, UpdateProfileState state) {
    return Column(
      children: [
        EditProfileFormField(
          label: "edit_profile.bio".tr(),
          hint: state.bio ?? "edit_profile.bio_hint".tr(),
          value: state.bio ?? '',
          maxLines: 4,
          onChanged: (value) =>
              context.read<UpdateProfileBloc>().add(UpdateBio(value)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "edit_profile.bio_description".tr(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationField(
      BuildContext context, UpdateProfileState state) {
    return BlocConsumer<SelectionOptionBloc, SelectionOptionState>(
      listener: (context, selectionState) {
        if (selectionState is SelectionOptionLoaded) {
          final selectionModel = selectionState.selectionModel;
          setState(() {
            _allAvailableSpecializations = selectionModel.specializations;
          });
        }
      },
      builder: (context, selectionState) {
        if (selectionState is SelectionOptionLoading ||
            selectionState is SelectionOptionInitial) {
          return LoadingDropDown(
            label: "edit_profile.specialization".tr(),
            loadingText: "Loading specializations...",
          );
        }
        if (selectionState is SelectionOptionLoaded) {
          return EditProfileSelectionField(
            label: "edit_profile.specialization".tr(),
            hintText: state.specializationName ??
                "edit_profile.specialization_hint".tr(),
            currentSelectionName: state.specializationName,
            options: _allAvailableSpecializations,
            onSelected: (id, name) {
              context.read<UpdateProfileBloc>().add(UpdateSpecialization(
                    id: int.parse(id),
                    name: name,
                  ));
            },
          );
        }
        return ErrorDropDown(
          label: "edit_profile.specialization".tr(),
          errorText: "Failed to load specializations.",
        );
      },
    );
  }

  Widget _buildJobTitleField(BuildContext context, UpdateProfileState state) {
    return BlocConsumer<SelectionOptionBloc, SelectionOptionState>(
      listener: (context, selectionState) {
        if (selectionState is SelectionOptionLoaded) {
          final selectionModel = selectionState.selectionModel;
          setState(() {
            _allAvailableJobTitles = selectionModel.jobTitles;
          });
        }
      },
      builder: (context, selectionState) {
        if (selectionState is SelectionOptionLoading ||
            selectionState is SelectionOptionInitial) {
          return LoadingDropDown(
            label: "edit_profile.job_title".tr(),
            loadingText: "Loading job titles...",
          );
        }
        if (selectionState is SelectionOptionLoaded) {
          return EditProfileSelectionField(
            label: "edit_profile.job_title".tr(),
            hintText: state.jobTitleName ?? "edit_profile.job_title_hint".tr(),
            currentSelectionName: state.jobTitleName,
            options: _allAvailableJobTitles,
            onSelected: (id, name) {
              context.read<UpdateProfileBloc>().add(UpdateJobTitle(
                    id: int.parse(id),
                    name: name,
                  ));
            },
          );
        }
        return ErrorDropDown(
          label: "edit_profile.job_title".tr(),
          errorText: "Failed to load job titles.",
        );
      },
    );
  }

  Widget _buildSkillsField(BuildContext context, UpdateProfileState state) {
    return BlocConsumer<SelectionOptionBloc, SelectionOptionState>(
      listener: (context, selectionState) {
        if (selectionState is SelectionOptionLoaded) {
          final selectionModel = selectionState.selectionModel;
          setState(() {
            _allAvailableSkills = selectionModel.skills;
          });
        }
      },
      builder: (context, selectionState) {
        if (selectionState is SelectionOptionLoading ||
            selectionState is SelectionOptionInitial) {
          return _buildSkillsLoadingState();
        }
        if (selectionState is SelectionOptionLoaded) {
          return EditProfileSkillsField(
            label: "edit_profile.skills".tr(),
            hintText: state.selectedSkills?.join(", ") ??
                "edit_profile.skills_hint".tr(),
            selectedSkills: state.selectedSkills ?? const [],
            allSkills: _allAvailableSkills,
            onSelectionChanged: (resultNames) {
              final skillIds = _getSkillIdsFromNames(resultNames);
              context.read<UpdateProfileBloc>().add(
                    UpdateSkills(skillIds: skillIds, skillNames: resultNames),
                  );
            },
          );
        }
        return _buildSkillsErrorState();
      },
    );
  }

  List<int> _getSkillIdsFromNames(List<String> skillNames) {
    return skillNames
        .map((name) {
          return _allAvailableSkills.entries
              .firstWhere((entry) => entry.value == name,
                  orElse: () => const MapEntry('0', ''))
              .key;
        })
        .where((id) => id != '0')
        .map(int.parse)
        .toList();
  }

  Widget _buildSkillsLoadingState() => LoadingDropDown(
        label: "edit_profile.skills".tr(),
        loadingText: "Loading skills...",
      );

  Widget _buildSkillsErrorState() => ErrorDropDown(
        label: "edit_profile.skills".tr(),
        errorText: "Failed to load skills. Please try again.",
      );

  Widget _buildPasswordFields(BuildContext context, UpdateProfileState state) {
    return Column(
      children: [
        EditProfileFormField(
          label: "edit_profile.new_password".tr(),
          hint: "edit_profile.password_hint".tr(),
          value: '',
          onChanged: (value) =>
              context.read<UpdateProfileBloc>().add(UpdateNewPassword(value)),
          obscureText: true,
          required: false,
        ),
        EditProfileFormField(
          label: "edit_profile.confirm_password".tr(),
          hint: "edit_profile.password_hint".tr(),
          value: '',
          onChanged: (value) => context
              .read<UpdateProfileBloc>()
              .add(UpdateConfirmPassword(value)),
          obscureText: true,
          required: false,
        ),
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: TextButton(
        //     onPressed: () {},
        //     child: Text(
        //       "edit_profile.change_password".tr(),
        //       style: const TextStyle(color: Color(0xFF00C4A1)),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, UpdateProfileState state) {
    return EditProfileSaveButton(
      isSubmitting: state.isSubmitting,
      onTap: () => context.read<UpdateProfileBloc>().add(SubmitProfile()),
      label: "edit_profile.save".tr(),
      loadingLabel: "edit_profile.saving".tr(),
    );
  }
}
