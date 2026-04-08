import 'dart:io';

import 'package:flutter/material.dart';

mixin IdentityVerificationFormMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController arabicFirstNameController =
      TextEditingController();
  final TextEditingController arabicFamilyNameController =
      TextEditingController();
  final TextEditingController englishFirstNameController =
      TextEditingController();
  final TextEditingController englishFamilyNameController =
      TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  final ValueNotifier<int> currentTabNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String?> selectedCountryIdNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<DateTime?> birthDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<bool> acknowledgedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<Map<int, File>> uploadedTabImagesNotifier =
      ValueNotifier<Map<int, File>>({});

  final List<String> tabTitleKeys = const [
    'identity_verification_screen.tab_info',
    'identity_verification_screen.tab_front',
    'identity_verification_screen.tab_back',
    'identity_verification_screen.tab_selfie',
  ];

  Listenable get screenListenable => Listenable.merge([
        currentTabNotifier,
        selectedCountryIdNotifier,
        birthDateNotifier,
        acknowledgedNotifier,
        uploadedTabImagesNotifier,
      ]);

  void updateUploadedTabImage(int tabIndex, File file) {
    final updated = Map<int, File>.from(uploadedTabImagesNotifier.value);
    updated[tabIndex] = file;
    uploadedTabImagesNotifier.value = updated;
  }

  int? get selectedCountryId {
    return int.tryParse(selectedCountryIdNotifier.value ?? '');
  }

  File? get idCardFrontFace => uploadedTabImagesNotifier.value[1];

  File? get idCardBackFace => uploadedTabImagesNotifier.value[2];

  File? get selfieWithIdCard => uploadedTabImagesNotifier.value[3];

  void disposeIdentityFormData() {
    arabicFirstNameController.dispose();
    arabicFamilyNameController.dispose();
    englishFirstNameController.dispose();
    englishFamilyNameController.dispose();
    birthDateController.dispose();

    currentTabNotifier.dispose();
    selectedCountryIdNotifier.dispose();
    birthDateNotifier.dispose();
    acknowledgedNotifier.dispose();
    uploadedTabImagesNotifier.dispose();
  }
}
