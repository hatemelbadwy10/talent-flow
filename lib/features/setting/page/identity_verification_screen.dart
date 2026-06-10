import 'dart:developer';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/user_completion_guard.dart';
import 'package:talent_flow/components/custom_network_image.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/setting/bloc/identity_verification_bloc.dart';
import 'package:talent_flow/features/setting/model/identity_verification_details.dart';
import 'package:talent_flow/features/setting/mixins/identity_verification_form_mixin.dart';
import 'package:talent_flow/features/setting/model/identity_verification_request.dart';
import 'package:talent_flow/features/setting/repo/settings_repo.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/helpers/date_time_picker.dart';
import 'package:talent_flow/helpers/pickers/view/image_picker_helper.dart';
import 'package:talent_flow/main_blocs/location_options_bloc.dart';

import '../../../components/custom_text_form_field.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen>
    with IdentityVerificationFormMixin {
  late final IdentityVerificationBloc _identityVerificationBloc;
  late final LocationOptionsBloc _locationOptionsBloc;
  late final SettingsRepo _settingsRepo;
  late final Dio _dio;
  bool _isUnderReview = false;
  bool _isLoadingExistingRequest = true;
  bool _showEditForm = false;
  IdentityVerificationDetails? _acceptedVerification;

  @override
  void initState() {
    super.initState();
    _identityVerificationBloc = IdentityVerificationBloc(sl());
    _settingsRepo = sl();
    _dio = sl();
    _locationOptionsBloc = LocationOptionsBloc(sl())
      ..add(const LoadCountries());
    _isUnderReview = _readIdentityVerifyStatus().toLowerCase() == 'processing';
    _loadExistingIdentityVerification();
  }

  @override
  void dispose() {
    _locationOptionsBloc.close();
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
    final isFormValid =
        formState?.validate() ?? _validateInfoValuesWhenFormHidden();

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
    log('Attempting to submit identity verification, validating inputs first');
    if (!_validateInfoTab() || !_validateUploadTabs()) {
      log('Validation failed, cannot submit identity verification');
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
      log('Next pressed on last tab, attempting to submit identity verification');
      _submitIdentityVerification();
      return;
    }

    if (currentTab < tabTitleKeys.length - 1) {
      currentTabNotifier.value = currentTab + 1;
    }
  }

  bool get _fromOnboarding => widget.arguments?['fromOnboarding'] == true;

  String _readIdentityVerifyStatus() {
    final rawUserData =
        sl<SharedPreferences>().getString(AppStorageKey.userData) ?? '';
    if (rawUserData.isEmpty) {
      return '';
    }

    try {
      final decoded = jsonDecode(rawUserData);
      if (decoded is Map) {
        return decoded['identity_verify_status']?.toString() ?? '';
      }
    } catch (_) {}

    return '';
  }

  Future<void> _loadExistingIdentityVerification() async {
    final result = await _settingsRepo.getIdentityVerification();
    if (!mounted) return;

    IdentityVerificationDetails? details;
    final failed = result.fold(
      (_) => true,
      (response) {
        details = response;
        return false;
      },
    );

    if (failed) {
      setState(() {
        _isLoadingExistingRequest = false;
      });
      return;
    }

    final normalizedStatus = details?.status.trim().toLowerCase() ?? '';
    final isAccepted = normalizedStatus == 'accepted';
    final isPending = _isPendingStatus(normalizedStatus);
    final shouldShowForm = normalizedStatus.isEmpty ||
        normalizedStatus == 'rejected' ||
        normalizedStatus == 'declined';

    if (details != null) {
      await _populateFormFromExistingRequest(details!);
    }

    await UserCompletionGuard.updateStoredFlags(
      identityAuthenticated: isAccepted,
      identityVerifyStatus: details?.status,
    );
    if (!mounted) return;

    setState(() {
      _acceptedVerification = isAccepted ? details : null;
      _isUnderReview = isPending;
      _isLoadingExistingRequest = false;
      _showEditForm = false;

      if (shouldShowForm) {
        _isUnderReview = false;
      }
    });
  }

  bool _isPendingStatus(String status) {
    return status == 'processing' ||
        status == 'pending' ||
        status == 'waiting' ||
        status == 'under review' ||
        status == 'under_review' ||
        status == 'in review' ||
        status == 'in_review';
  }

  Future<void> _populateFormFromExistingRequest(
    IdentityVerificationDetails details,
  ) async {
    arabicFirstNameController.text = details.firstNameAr;
    arabicFamilyNameController.text = details.lastNameAr;
    englishFirstNameController.text = details.firstNameEn;
    englishFamilyNameController.text = details.lastNameEn;
    birthDateController.text = details.dateOfBirth;
    acknowledgedNotifier.value = true;

    if (details.dateOfBirth.isNotEmpty) {
      birthDateNotifier.value = DateTime.tryParse(details.dateOfBirth);
    }
    if (details.countryId != null) {
      selectedCountryIdNotifier.value = details.countryId.toString();
    }

    await _hydrateExistingImages(details);
  }

  Future<void> _hydrateExistingImages(
    IdentityVerificationDetails details,
  ) async {
    final downloads = await Future.wait([
      _downloadImageToTempFile(details.idCardFrontFace, 'front'),
      _downloadImageToTempFile(details.idCardBackFace, 'back'),
      _downloadImageToTempFile(details.selfieWithIdCard, 'selfie'),
    ]);

    final updated = Map<int, File>.from(uploadedTabImagesNotifier.value);
    if (downloads[0] != null) updated[1] = downloads[0]!;
    if (downloads[1] != null) updated[2] = downloads[1]!;
    if (downloads[2] != null) updated[3] = downloads[2]!;
    uploadedTabImagesNotifier.value = updated;
  }

  Future<File?> _downloadImageToTempFile(String url, String prefix) async {
    if (url.trim().isEmpty) return null;

    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;

      final tempDir = await getTemporaryDirectory();
      final uri = Uri.tryParse(url);
      final extension = path.extension(uri?.path ?? '');
      final safeExtension = extension.isEmpty ? '.png' : extension;
      final file = File(
        '${tempDir.path}/identity_${prefix}_${DateTime.now().microsecondsSinceEpoch}$safeExtension',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (error, stackTrace) {
      log(
        'Failed to hydrate identity verification image',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _identityVerificationBloc),
        BlocProvider.value(value: _locationOptionsBloc),
      ],
      child: BlocListener<IdentityVerificationBloc, AppState>(
        listener: (context, state) async {
          if (state is Done) {
            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);

            await UserCompletionGuard.updateStoredFlags(
              identityVerifyStatus: 'Processing',
            );
            if (!mounted) return;

            setState(() {
              _isUnderReview = true;
            });

            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'identity_verification_screen.submit_processing'.tr(),
                ),
              ),
            );

            if (_fromOnboarding) {
              CustomNavigator.push(Routes.navBar, clean: true);
            } else {
              navigator.pop(true);
            }
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
                actions: _fromOnboarding
                    ? [
                        TextButton(
                          onPressed: () {
                            UserCompletionGuard.handlePostAuthNavigation(
                              skipIdentityVerification: true,
                            );
                          },
                          child: Text(
                            'user_completion.skip'.tr(),
                            style: const TextStyle(
                              color: Styles.PRIMARY_COLOR,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ]
                    : null,
              ),
              body: AnimatedBuilder(
                animation: screenListenable,
                builder: (context, _) {
                  if (_isLoadingExistingRequest) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_acceptedVerification != null && !_showEditForm) {
                    return _buildAcceptedState(_acceptedVerification!);
                  }

                  if (_isUnderReview) {
                    return _buildUnderReviewState();
                  }

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
          BlocBuilder<LocationOptionsBloc, LocationOptionsState>(
            builder: (context, locationState) {
              final countries = locationState.countries;
              final selectedCountryId = selectedCountryIdNotifier.value;
              final hasSelectedCountry = selectedCountryId != null &&
                  countries.containsKey(selectedCountryId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedCountryId),
                    initialValue: hasSelectedCountry ? selectedCountryId : null,
                    decoration: InputDecoration(
                      labelText: 'identity_verification_screen.country'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: locationState.isLoadingCountries
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    items: countries.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'identity_verification_screen.required_field'
                            .tr();
                      }
                      return null;
                    },
                    onChanged: locationState.isLoadingCountries
                        ? null
                        : (value) => selectedCountryIdNotifier.value = value,
                  ),
                  if ((locationState.countriesError ?? '').isNotEmpty &&
                      countries.isEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            locationState.countriesError!,
                            style: const TextStyle(
                              color: Styles.FAILED_COLOR,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<LocationOptionsBloc>()
                                .add(const LoadCountries());
                          },
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
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

  Widget _buildUnderReviewState() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Styles.PRIMARY_COLOR.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 42,
                  color: Styles.PRIMARY_COLOR,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'identity_verification_screen.under_review_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'identity_verification_screen.under_review_message'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptedState(IdentityVerificationDetails details) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF2E7D32),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'identity_verification_screen.accepted_title'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'identity_verification_screen.accepted_message'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF4E5A54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAcceptedInfoCard(details),
            const SizedBox(height: 16),
            _buildAcceptedImages(details),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showEditForm = true;
                    currentTabNotifier.value = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'identity_verification_screen.show_form'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedInfoCard(IdentityVerificationDetails details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'identity_verification_screen.saved_data'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'identity_verification_screen.ar_first_name'.tr(),
            details.firstNameAr,
          ),
          _buildInfoRow(
            'identity_verification_screen.ar_family_name'.tr(),
            details.lastNameAr,
          ),
          _buildInfoRow(
            'identity_verification_screen.en_first_name'.tr(),
            details.firstNameEn,
          ),
          _buildInfoRow(
            'identity_verification_screen.en_family_name'.tr(),
            details.lastNameEn,
          ),
          _buildInfoRow(
            'identity_verification_screen.country'.tr(),
            details.country,
          ),
          _buildInfoRow(
            'identity_verification_screen.birth_date'.tr(),
            details.dateOfBirth,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedImages(IdentityVerificationDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'identity_verification_screen.documents'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildDocumentPreview(
          title: 'identity_verification_screen.tab_front'.tr(),
          imageUrl: details.idCardFrontFace,
        ),
        const SizedBox(height: 12),
        _buildDocumentPreview(
          title: 'identity_verification_screen.tab_back'.tr(),
          imageUrl: details.idCardBackFace,
        ),
        const SizedBox(height: 12),
        _buildDocumentPreview(
          title: 'identity_verification_screen.tab_selfie'.tr(),
          imageUrl: details.selfieWithIdCard,
        ),
      ],
    );
  }

  Widget _buildDocumentPreview({
    required String title,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomNetworkImage.containerNewWorkImage(
              image: imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              radius: 12,
            ),
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
