import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/setting/bloc/identity_verification_bloc.dart';
import 'package:talent_flow/features/setting/mixins/identity_verification_form_mixin.dart';
import 'package:talent_flow/features/setting/model/identity_verification_request.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/helpers/date_time_picker.dart';
import 'package:talent_flow/helpers/pickers/view/image_picker_helper.dart';

import '../../../components/custom_text_form_field.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen>
    with IdentityVerificationFormMixin {
  late final IdentityVerificationBloc _identityVerificationBloc;

  @override
  void initState() {
    super.initState();
    _identityVerificationBloc = IdentityVerificationBloc(sl());
  }

  @override
  void dispose() {
    _identityVerificationBloc.close();
    disposeIdentityFormData();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimePicker(
        label: 'identity_verification_screen.birth_date'.tr(),
        startDateTime: birthDateNotifier.value ?? DateTime.now(),
        minDateTime: DateTime(1900),
        valueChanged: (value) {
          birthDateNotifier.value = value;
          birthDateController.text = _formatDate(value);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  bool _validateInfoTab() {
    final formState = formKey.currentState;
    final isFormValid = formState?.validate() ?? _validateInfoValuesWhenFormHidden();

    if (!isFormValid && formState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('identity_verification_screen.required_field'.tr()),
        ),
      );
    }

    if (!acknowledgedNotifier.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'identity_verification_screen.invalid_checkbox_message'.tr()),
        ),
      );
    }
    return isFormValid && acknowledgedNotifier.value;
  }

  bool _validateInfoValuesWhenFormHidden() {
    final arabicPattern = RegExp(r'^[\u0600-\u06FF\s]+$');
    final englishPattern = RegExp(r'^[A-Za-z\s]+$');

    final firstAr = arabicFirstNameController.text.trim();
    final lastAr = arabicFamilyNameController.text.trim();
    final firstEn = englishFirstNameController.text.trim();
    final lastEn = englishFamilyNameController.text.trim();
    final birthDate = birthDateController.text.trim();

    if (firstAr.isEmpty ||
        lastAr.isEmpty ||
        firstEn.isEmpty ||
        lastEn.isEmpty ||
        birthDate.isEmpty) {
      return false;
    }
    if (!arabicPattern.hasMatch(firstAr) || !arabicPattern.hasMatch(lastAr)) {
      return false;
    }
    if (!englishPattern.hasMatch(firstEn) || !englishPattern.hasMatch(lastEn)) {
      return false;
    }
    if (selectedCountryId == null || birthDateNotifier.value == null) {
      return false;
    }
    return true;
  }

  bool _validateUploadTabs() {
    if (idCardFrontFace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'identity_verification_screen.front_image_required'.tr(),
          ),
        ),
      );
      currentTabNotifier.value = 1;
      return false;
    }
    if (idCardBackFace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'identity_verification_screen.back_image_required'.tr(),
          ),
        ),
      );
      currentTabNotifier.value = 2;
      return false;
    }
    if (selfieWithIdCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'identity_verification_screen.selfie_image_required'.tr(),
          ),
        ),
      );
      currentTabNotifier.value = 3;
      return false;
    }
    return true;
  }

  void _submitIdentityVerification() {
    log(  'Attempting to submit identity verification, validating inputs first');
    if (!_validateInfoTab() || !_validateUploadTabs()) {
      log(  'Validation failed, cannot submit identity verification');
      return;
    }

    final countryId = selectedCountryId;
    final front = idCardFrontFace;
    final back = idCardBackFace;
    final selfie = selfieWithIdCard;

    if (countryId == null || front == null || back == null || selfie == null) {
      return;
    }
    log('Submitting identity verification with countryId: $countryId, front: ${front.path}, back: ${back.path}, selfie: ${selfie.path}');

    _identityVerificationBloc.add(
          Add(
            arguments: IdentityVerificationRequest(
              countryId: countryId,
              firstNameAr: arabicFirstNameController.text.trim(),
              lastNameAr: arabicFamilyNameController.text.trim(),
              firstNameEn: englishFirstNameController.text.trim(),
              lastNameEn: englishFamilyNameController.text.trim(),
              dateOfBirth: birthDateController.text.trim(),
              idCardFrontFace: front,
              idCardBackFace: back,
              selfieWithIdCard: selfie,
            ),
          ),
        );
  }

  void _onTabPressed(int targetIndex) {
    final currentTab = currentTabNotifier.value;
    if (targetIndex <= currentTab) {
      currentTabNotifier.value = targetIndex;
      return;
    }

    if (_validateInfoTab()) {
      currentTabNotifier.value = targetIndex;
    }
  }

  void _onNextPressed() {
    final currentTab = currentTabNotifier.value;
    if (currentTab == 0 && !_validateInfoTab()) return;

    if (currentTab == tabTitleKeys.length - 1) {
      log(  'Next pressed on last tab, attempting to submit identity verification');
      _submitIdentityVerification();
      return;
    }

    if (currentTab < tabTitleKeys.length - 1) {
      currentTabNotifier.value = currentTab + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _identityVerificationBloc,
      child: BlocListener<IdentityVerificationBloc, AppState>(
        listener: (context, state) {
          if (state is Done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('identity_verification_screen.submit_success'.tr()),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('identity_verification_screen.submit_error'.tr()),
              ),
            );
          }
        },
        child: BlocBuilder<IdentityVerificationBloc, AppState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: 'settings_screen.identity_verification'.tr(),
              ),
              body: AnimatedBuilder(
                animation: screenListenable,
                builder: (context, _) {
                  final currentTab = currentTabNotifier.value;
                  final isSubmitting = state is Loading;

                  return SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  List.generate(tabTitleKeys.length, (index) {
                                final isActive = index == currentTab;
                                return Padding(
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 8),
                                  child: InkWell(
                                    onTap: () => _onTabPressed(index),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minWidth: 140),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Styles.PRIMARY_COLOR
                                            : Styles.PRIMARY_COLOR
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        tabTitleKeys[index].tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isActive
                                              ? Colors.white
                                              : Styles.PRIMARY_COLOR,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: currentTab == 0
                                ? _buildInfoForm()
                                : _buildUploadTab(currentTab),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _onNextPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.PRIMARY_COLOR,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      currentTab == tabTitleKeys.length - 1
                                          ? 'identity_verification_screen.submit'
                                              .tr()
                                          : 'identity_verification_screen.next_step'
                                              .tr(),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _textField(
            controller: arabicFirstNameController,
            label: 'identity_verification_screen.ar_first_name'.tr(),
            arabicOnly: true,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: arabicFamilyNameController,
            label: 'identity_verification_screen.ar_family_name'.tr(),
            arabicOnly: true,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: englishFirstNameController,
            label: 'identity_verification_screen.en_first_name'.tr(),
            englishOnly: true,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: englishFamilyNameController,
            label: 'identity_verification_screen.en_family_name'.tr(),
            englishOnly: true,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(selectedCountryKeyNotifier.value),
            initialValue: selectedCountryKeyNotifier.value,
            decoration: InputDecoration(
              labelText: 'identity_verification_screen.country'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: countryKeys
                .map(
                  (key) => DropdownMenuItem<String>(
                    value: key,
                    child: Text(key.tr()),
                  ),
                )
                .toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'identity_verification_screen.required_field'.tr();
              }
              return null;
            },
            onChanged: (value) => selectedCountryKeyNotifier.value = value,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: birthDateController,
            withLabel: true,
            label: 'identity_verification_screen.birth_date'.tr(),
            hint: 'identity_verification_screen.birth_date'.tr(),
            readOnly: true,
            onTap: _pickBirthDate,
            validate: (value) {
              if (value == null ||
                  value.isEmpty ||
                  birthDateNotifier.value == null) {
                return 'identity_verification_screen.required_field'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: acknowledgedNotifier.value,
            activeColor: Styles.PRIMARY_COLOR,
            onChanged: (value) => acknowledgedNotifier.value = value ?? false,
            title: Text(
              'identity_verification_screen.acknowledgment'.tr(),
              style: const TextStyle(fontSize: 13),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTab(int tabIndex) {
    final subtitleKey = switch (tabIndex) {
      1 => 'identity_verification_screen.subtitle_front',
      2 => 'identity_verification_screen.subtitle_back',
      _ => 'identity_verification_screen.subtitle_selfie',
    };
    final File? selectedImage = uploadedTabImagesNotifier.value[tabIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Text(
          'settings_screen.identity_verification'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitleKey.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 16),
        selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  selectedImage,
                  width: 343,
                  height: 343,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/images/Image upload-bro 1.png',
                width: 343,
                height: 343,
                fit: BoxFit.contain,
              ),
        const SizedBox(height: 16),
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ImagePickerHelper.openCamera(onGet: (file) {
                    updateUploadedTabImage(tabIndex, file);
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Styles.PRIMARY_COLOR),
                  foregroundColor: Styles.PRIMARY_COLOR,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('identity_verification_screen.from_camera'.tr()),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ImagePickerHelper.openGallery(onGet: (file) {
                    updateUploadedTabImage(tabIndex, file);
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Styles.PRIMARY_COLOR),
                  foregroundColor: Styles.PRIMARY_COLOR,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('identity_verification_screen.from_studio'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    bool arabicOnly = false,
    bool englishOnly = false,
  }) {
    final arabicPattern = RegExp(r'^[\u0600-\u06FF\s]+$');
    final englishPattern = RegExp(r'^[A-Za-z\s]+$');

    return CustomTextField(
      controller: controller,
      withLabel: true,
      label: label,
      hint: label,
      formattedType: arabicOnly
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]'))]
          : englishOnly
              ? [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]'))]
              : null,
      validate: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return 'identity_verification_screen.required_field'.tr();
        }
        if (arabicOnly && !arabicPattern.hasMatch(text)) {
          return 'identity_verification_screen.invalid_arabic_chars'.tr();
        }
        if (englishOnly && !englishPattern.hasMatch(text)) {
          return 'identity_verification_screen.invalid_english_chars'.tr();
        }
        return null;
      },
    );
  }
}
