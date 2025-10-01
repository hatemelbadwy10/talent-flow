import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/setting/bloc/update_profile_bloc.dart';
import 'package:talent_flow/features/setting/bloc/update_profile_event.dart';
import 'package:talent_flow/features/setting/bloc/update_profile_state.dart';
import 'package:talent_flow/features/setting/widgets/error_drop_down.dart';
import 'package:talent_flow/features/setting/widgets/loading_drop_down.dart';
import 'package:talent_flow/features/setting/widgets/multi_select_skills_dialog.dart';
import 'package:talent_flow/features/setting/widgets/single_select_dialoug.dart';
import 'package:talent_flow/app/core/images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_bloc.dart';
import 'package:talent_flow/features/new_projects/model/selection_option_model.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';

import '../../../helpers/pickers/view/image_picker_helper.dart';
import '../repo/update_profile_repo.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SelectionOptionBloc(sl())..add(Add()),
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
            Images.appLogo ?? "",
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
        body: const EditProfileForm(),
      ),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Map<String, String> _allAvailableSkills = {};
  Map<String, String> _allAvailableSpecializations = {};
  Map<String, String> _allAvailableJobTitles = {};

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
      listener: (context, state) {
        if (state.isSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('edit_profile.success'.tr())),
          );
          Navigator.of(context).pop();
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFCEE5E6),
      ),
      child: Column(
        children: [
          SizedBox(height: 43.h),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image:state.image != null
                        ? FileImage(state.image!) as ImageProvider
                        : NetworkImage(sl<SharedPreferences>().getString(AppStorageKey.userImage) ?? Images.appLogo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: const Icon(
                    Icons.edit,
                    color: Styles.PRIMARY_COLOR,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      ImagePickerHelper.openCamera(onGet: (file){
                        context.read<UpdateProfileBloc>().add(UpdateImage(file));
                      });
                    },
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.grey)),
                IconButton(
                    onPressed: () {
                      ImagePickerHelper.openGallery(onGet: (file){
                        context.read<UpdateProfileBloc>().add(UpdateImage(file));
                      });
                    },
                    icon: const Icon(Icons.image_outlined, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameFields(BuildContext context, UpdateProfileState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTextField(
            label: "edit_profile.first_name".tr(),
            hint: state.firstName??"edit_profile.first_name_hint".tr(),
            value: state.firstName ?? '',
            onChanged: (value) => context.read<UpdateProfileBloc>().add(UpdateFirstName(value)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: "edit_profile.last_name".tr(),
          hint: state.lastName??"edit_profile.last_name_hint".tr(),
            value: state.lastName ?? '',
            onChanged: (value) => context.read<UpdateProfileBloc>().add(UpdateLastName(value)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, UpdateProfileState state) {
    return _buildTextField(
      label: "edit_profile.email".tr(),
      hint: state.email?? "edit_profile.email_hint".tr(),
      value: state.email ?? '',
      onChanged: (value) => context.read<UpdateProfileBloc>().add(UpdateEmail(value)),
    );
  }

  Widget _buildPhoneField(BuildContext context, UpdateProfileState state) {
    return _buildTextField(
      label: "edit_profile.phone".tr(),
      hint: state.phone??"edit_profile.phone_hint".tr(),
      value: state.phone ?? '',
      onChanged: (value) => context.read<UpdateProfileBloc>().add(UpdatePhone(value)),
    );
  }

  Widget _buildBioField(BuildContext context, UpdateProfileState state) {
    return _buildTextField(
      label: "edit_profile.bio".tr(),
      hint: state.bio??"edit_profile.bio_hint".tr(),
      value: state.bio ?? '',
      maxLines: 4,
      onChanged: (value) => context.read<UpdateProfileBloc>().add(UpdateBio(value)),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
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
          CustomTextField(
            initialValue: value,
            hint: hint,
            maxLines: maxLines,
            obscureText: obscureText,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationField(BuildContext context, UpdateProfileState state) {
    return BlocConsumer<SelectionOptionBloc, AppState>(
      listener: (context, selectionState) {
        if (selectionState is Done && selectionState.model is SelectionModel) {
          final selectionModel = selectionState.model as SelectionModel;
          setState(() {
            _allAvailableSpecializations = selectionModel.specializations;
          });
        }
      },
      builder: (context, selectionState) {
        if (selectionState is Loading || selectionState is Start) {
          return LoadingDropDown(
            label: "edit_profile.specialization".tr(),
            loadingText: "Loading specializations...",
          );
        }
        if (selectionState is Done && selectionState.model is SelectionModel) {
          return _buildSingleSelectDropdownField(
            label: "edit_profile.specialization".tr(),
            hintText: state.specializationName??"edit_profile.specialization_hint".tr(),
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
    return BlocConsumer<SelectionOptionBloc, AppState>(
      listener: (context, selectionState) {
        if (selectionState is Done && selectionState.model is SelectionModel) {
          final selectionModel = selectionState.model as SelectionModel;
          setState(() {
            _allAvailableJobTitles = selectionModel.jobTitles;
          });
        }
      },
      builder: (context, selectionState) {
        if (selectionState is Loading || selectionState is Start) {
          return LoadingDropDown(
            label: "edit_profile.job_title".tr(),
            loadingText: "Loading job titles...",
          );
        }
        if (selectionState is Done && selectionState.model is SelectionModel) {
          return _buildSingleSelectDropdownField(
            label: "edit_profile.job_title".tr(),
            hintText: state.jobTitleName??"edit_profile.job_title_hint".tr(),
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

  Widget _buildSingleSelectDropdownField({
    required String label,
    required String hintText,
    required String? currentSelectionName,
    required Map<String, String> options,
    required Function(String id, String name) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
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
          GestureDetector(
            onTap: () async {
              final String? resultId = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return SingleSelectDialog(
                    title: label,
                    options: options,
                    initialSelectedId: options.containsValue(currentSelectionName)
                        ? options.entries
                        .firstWhere((element) => element.value == currentSelectionName)
                        .key
                        : null,
                  );
                },
              );

              if (resultId != null && options.containsKey(resultId)) {
                onSelected(resultId, options[resultId]!);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      currentSelectionName ?? hintText,
                      style: TextStyle(
                        color: currentSelectionName != null
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsField(BuildContext context, UpdateProfileState state) {
    return BlocConsumer<SelectionOptionBloc, AppState>(
      listener: (context, selectionState) {
        if (selectionState is Done && selectionState.model is SelectionModel) {
          final selectionModel = selectionState.model as SelectionModel;
          setState(() {
            _allAvailableSkills = selectionModel.skills;
          });
        }
      },
      builder: (context, selectionState) {
        if (selectionState is Loading || selectionState is Start) {
          return _buildSkillsLoadingState();
        }
        if (selectionState is Done && selectionState.model is SelectionModel) {
          return _buildSkillsSelectionField(
            context,
            state,
            "edit_profile.skills".tr(),
           state.selectedSkills?.join(", ") ?? "edit_profile.skills_hint".tr(),
          );
        }
        return _buildSkillsErrorState();
      },
    );
  }

  Widget _buildSkillsSelectionField(
      BuildContext context, UpdateProfileState state, String label, String hintText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
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
          GestureDetector(
            onTap: () async {
              // Get skill IDs from names
              final selectedSkillIds = _getSkillIdsFromNames(state.selectedSkills ?? []);

              final List<String>? resultNames = await showDialog<List<String>>(
                context: context,
                builder: (BuildContext context) {
                  return MultiSelectSkillsDialog(
                    allSkills: _allAvailableSkills.values.toList(),
                    initialSelectedSkills: state.selectedSkills ?? [],
                  );
                },
              );

              if (resultNames != null) {
                final skillIds = _getSkillIdsFromNames(resultNames);
                context.read<UpdateProfileBloc>().add(
                  UpdateSkills(skillIds: skillIds, skillNames: resultNames),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: (state.selectedSkills ?? []).isEmpty
                        ? Text(hintText, style: TextStyle(color: Colors.grey.shade600))
                        : Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: (state.selectedSkills ?? []).map((skillName) {
                        return Chip(
                          label: Text(skillName),
                          onDeleted: () {
                            final updatedSkills = List<String>.from(state.selectedSkills ?? []);
                            updatedSkills.remove(skillName);
                            final skillIds = _getSkillIdsFromNames(updatedSkills);
                            context.read<UpdateProfileBloc>().add(
                              UpdateSkills(skillIds: skillIds, skillNames: updatedSkills),
                            );
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getSkillIdsFromNames(List<String> skillNames) {
    return skillNames.map((name) {
      return _allAvailableSkills.entries
          .firstWhere((entry) => entry.value == name,
          orElse: () => MapEntry('0', ''))
          .key;
    }).where((id) => id != '0').map(int.parse).toList();
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
        _buildPasswordField(
          label: "edit_profile.new_password".tr(),
          hint: "edit_profile.password_hint".tr(),
          controller: _newPasswordController,
          onChanged: (value) => context.read<UpdateProfileBloc>().add(UpdateNewPassword(value)),
        ),
        _buildPasswordField(
          label: "edit_profile.confirm_password".tr(),
          hint: "edit_profile.password_hint".tr(),
          controller: _confirmPasswordController,
          onChanged: (value) => context.read<UpdateProfileBloc>().add(UpdateConfirmPassword(value)),
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

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8.0),
          CustomTextField(
            controller: controller,
            hint: hint,
            obscureText: true,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, UpdateProfileState state) {
    return CustomButton(
      onTap: state.isSubmitting
          ? null
          : () => context.read<UpdateProfileBloc>().add(SubmitProfile()),
      text: state.isSubmitting ? "edit_profile.saving".tr() : "edit_profile.save".tr(),
    );
  }
}