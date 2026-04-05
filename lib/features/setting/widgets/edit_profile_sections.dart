import 'dart:io';

import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/features/setting/widgets/multi_select_skills_dialog.dart';
import 'package:talent_flow/features/setting/widgets/single_select_dialoug.dart';

class EditProfileHeaderSection extends StatelessWidget {
  const EditProfileHeaderSection({
    super.key,
    required this.image,
    required this.imageUrl,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final File? image;
  final String imageUrl;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final imageProvider = image != null
        ? FileImage(image!) as ImageProvider
        : NetworkImage(imageUrl);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFCEE5E6),
      ),
      child: Column(
        children: [
          const SizedBox(height: 43),
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
                    image: imageProvider,
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                  onPressed: onCameraTap,
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: onGalleryTap,
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileFormField extends StatelessWidget {
  const EditProfileFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.required = true,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final bool obscureText;
  final bool readOnly;
  final bool required;

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ]
                  : const [],
            ),
          ),
          const SizedBox(height: 8.0),
          CustomTextField(
            initialValue: value,
            hint: hint,
            maxLines: maxLines,
            obscureText: obscureText,
            readOnly: readOnly,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class EditProfileSelectionField extends StatelessWidget {
  const EditProfileSelectionField({
    super.key,
    required this.label,
    required this.hintText,
    required this.currentSelectionName,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String hintText;
  final String? currentSelectionName;
  final Map<String, String> options;
  final void Function(String id, String name) onSelected;

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () async {
              final resultId = await showDialog<String>(
                context: context,
                builder: (dialogContext) {
                  return SingleSelectDialog(
                    title: label,
                    options: options,
                    initialSelectedId:
                        options.containsValue(currentSelectionName)
                            ? options.entries
                                .firstWhere(
                                  (element) =>
                                      element.value == currentSelectionName,
                                )
                                .key
                            : null,
                  );
                },
              );

              if (!context.mounted) return;
              if (resultId != null && options.containsKey(resultId)) {
                onSelected(resultId, options[resultId]!);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
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
}

class EditProfileSkillsField extends StatelessWidget {
  const EditProfileSkillsField({
    super.key,
    required this.label,
    required this.hintText,
    required this.selectedSkills,
    required this.allSkills,
    required this.onSelectionChanged,
  });

  final String label;
  final String hintText;
  final List<String> selectedSkills;
  final Map<String, String> allSkills;
  final ValueChanged<List<String>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () async {
              final resultNames = await showDialog<List<String>>(
                context: context,
                builder: (dialogContext) {
                  return MultiSelectSkillsDialog(
                    allSkills: allSkills.values.toList(),
                    initialSelectedSkills: selectedSkills,
                  );
                },
              );

              if (!context.mounted || resultNames == null) return;
              onSelectionChanged(resultNames);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: selectedSkills.isEmpty
                        ? Text(
                            hintText,
                            style: TextStyle(color: Colors.grey.shade600),
                          )
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: selectedSkills.map((skillName) {
                              return Chip(
                                label: Text(skillName),
                                onDeleted: () {
                                  final updatedSkills =
                                      List<String>.from(selectedSkills)
                                        ..remove(skillName);
                                  onSelectionChanged(updatedSkills);
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
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
}

class EditProfileSaveButton extends StatelessWidget {
  const EditProfileSaveButton({
    super.key,
    required this.isSubmitting,
    required this.onTap,
    required this.label,
    required this.loadingLabel,
  });

  final bool isSubmitting;
  final VoidCallback? onTap;
  final String label;
  final String loadingLabel;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onTap: isSubmitting ? null : onTap,
      text: isSubmitting ? loadingLabel : label,
    );
  }
}
