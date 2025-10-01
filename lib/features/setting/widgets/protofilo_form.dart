import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/helpers/date_time_picker.dart';
import 'package:talent_flow/helpers/pickers/view/image_picker_helper.dart';
import 'package:talent_flow/features/setting/bloc/portofilo_form_bloc.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class PortfolioUploadForm extends StatefulWidget {
  const PortfolioUploadForm({super.key});

  @override
  State<PortfolioUploadForm> createState() => _PortfolioUploadFormState();
}

class _PortfolioUploadFormState extends State<PortfolioUploadForm> {
  final List<TextEditingController> _titleControllers =
  List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _descriptionControllers =
  List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _featuresControllers =
  List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _linkControllers =
  List.generate(3, (_) => TextEditingController());

  // Validation errors map
  final Map<String, String?> _validationErrors = {};

  @override
  void dispose() {
    for (int i = 0; i < 3; i++) {
      _titleControllers[i].dispose();
      _descriptionControllers[i].dispose();
      _featuresControllers[i].dispose();
      _linkControllers[i].dispose();
    }
    super.dispose();
  }

  // Validation methods
  bool _isValidUrl(String url) {
    if (url.trim().isEmpty) return false;

    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(url.trim());
  }

  void _validateForm(PortfolioFormsState formState) {
    _validationErrors.clear();

    for (int i = 0; i < 3; i++) {
      final formData = formState.forms[i];

      // Title validation
      if (formData.title.trim().isEmpty) {
        _validationErrors['title_$i'] = 'Title is required';
      }

      // Thumbnail validation
      if (formData.image == null) {
        _validationErrors['image_$i'] = 'Thumbnail is required';
      }

      // Description validation
      if (formData.description.trim().isEmpty) {
        _validationErrors['description_$i'] = 'Description is required';
      }

      // Preview link validation
      if (formData.clientLink.trim().isEmpty) {
        _validationErrors['link_$i'] = 'Preview link is required';
      } else if (!_isValidUrl(formData.clientLink)) {
        _validationErrors['link_$i'] = 'Please enter a valid URL (e.g., https://example.com)';
      }
    }
  }

  bool _isFormValid(PortfolioFormsState formState) {
    // Check if terms are accepted
    if (!formState.termsOneAccepted || !formState.termsTwoAccepted) {
      return false;
    }

    _validateForm(formState);
    return _validationErrors.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioFormBloc, AppState>(
      builder: (context, state) {
        if (state is Loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is! Done || state.data is! PortfolioFormsState) {
          return Center(child: Text("initializing_form".tr()));
        }

        final formState = state.data as PortfolioFormsState;

        for (int i = 0; i < 3; i++) {
          final formData = formState.forms[i];
          if (_titleControllers[i].text != formData.title) {
            _titleControllers[i].text = formData.title;
          }
          if (_descriptionControllers[i].text != formData.description) {
            _descriptionControllers[i].text = formData.description;
          }
          if (_featuresControllers[i].text != formData.features) {
            _featuresControllers[i].text = formData.features;
          }
          if (_linkControllers[i].text != formData.clientLink) {
            _linkControllers[i].text = formData.clientLink;
          }
        }

        final bool isFormValid = _isFormValid(formState);

        return Column(
          children: [
            ...List.generate(
              3,
                  (index) => _buildCollapsibleFormCard(
                context: context,
                formIndex: index,
                formState: formState,
              ),
            ),
            const SizedBox(height: 24),
            _buildTermsConfirmationCard(context, formState),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid
                    ? () => context
                    .read<PortfolioFormBloc>()
                    .add(SubmitAllPortfolios())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid
                      ? Styles.PRIMARY_COLOR
                      : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "submit_all_works".tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isFormValid ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermsConfirmationCard(
      BuildContext context, PortfolioFormsState formState) {
    final bloc = context.read<PortfolioFormBloc>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Text(
            "confirm_terms".tr(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          ),
          const SizedBox(height: 16.0),
          _buildSingleCheckboxRow(
            text: "term_one".tr(),
            value: formState.termsOneAccepted,
            onChanged: (newValue) =>
                bloc.add(UpdateSingleTerm(termIndex: 1, isAccepted: newValue!)),
          ),
          const SizedBox(height: 12.0),
          _buildSingleCheckboxRow(
            text: "term_two".tr(),
            value: formState.termsTwoAccepted,
            onChanged: (newValue) =>
                bloc.add(UpdateSingleTerm(termIndex: 2, isAccepted: newValue!)),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCheckboxRow({
    required String text,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        SizedBox(
          height: 24.0,
          width: 24.0,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Styles.PRIMARY_COLOR,
            side: BorderSide(color: Colors.grey.shade400, width: 2),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleFormCard({
    required BuildContext context,
    required int formIndex,
    required PortfolioFormsState formState,
  }) {
    final bool isExpanded = formState.expandedFormIndex == formIndex;
    final bloc = context.read<PortfolioFormBloc>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => bloc.add(ExpandForm(formIndex: formIndex)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
    Text(
        "work_number".tr(args: ['${formIndex + 1}']),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Icon(isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? _buildFormBody(context, formIndex, formState.forms[formIndex])
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBody(
      BuildContext context, int formIndex, SinglePortfolioData formData) {
    final bloc = context.read<PortfolioFormBloc>();
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "work_title".tr() + " *",
                hint: "work_title_hint".tr(),
                controller: _titleControllers[formIndex],
                onChanged: (value) => bloc.add(UpdateFormField(
                    formIndex: formIndex, fieldName: 'title', value: value)),
              ),
              if (_validationErrors['title_$formIndex'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _validationErrors['title_$formIndex']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildThumbnailField(context, formIndex, formData.image),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "work_description".tr() + " *",
                hint: "work_description_hint".tr(),
                controller: _descriptionControllers[formIndex],
                maxLines: 4,
                onChanged: (value) => bloc.add(UpdateFormField(
                    formIndex: formIndex, fieldName: 'description', value: value)),
              ),
              if (_validationErrors['description_$formIndex'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _validationErrors['description_$formIndex']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            label: "work_features".tr(),
            hint: "work_features_hint".tr(),
            controller: _featuresControllers[formIndex],
            maxLines: 3,
            onChanged: (value) => bloc.add(UpdateFormField(
                formIndex: formIndex, fieldName: 'features', value: value)),
          ),
          const SizedBox(height: 16.0),
          _buildFilesField(context, formIndex, formData.files),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "preview_link".tr() + " *",
                hint: "preview_link_hint".tr(),
                controller: _linkControllers[formIndex],
                onChanged: (value) => bloc.add(UpdateFormField(
                    formIndex: formIndex, fieldName: 'clientLink', value: value)),
              ),
              if (_validationErrors['link_$formIndex'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _validationErrors['link_$formIndex']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildDateField(context, formIndex, formData.date),
        ],
      ),
    );
  }

  Widget _buildThumbnailField(
      BuildContext context, int formIndex, File? image) {
    final bloc = context.read<PortfolioFormBloc>();
    final hasError = _validationErrors['image_$formIndex'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "thumbnail".tr() + " *",
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: () async {
            await ImagePickerHelper.openGallery(onGet: (file) {
              bloc.add(UpdateFormImage(formIndex: formIndex, image: file));
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: hasError ? Colors.red : Colors.grey.shade300,
                  width: hasError ? 2 : 1
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  if (image != null)
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: FileImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.cloud_upload_outlined,
                        color: Colors.grey.shade500, size: 32),
                  const SizedBox(height: 8.0),
                  Text(
                    image != null
                        ? "thumbnail_uploaded".tr()
                        : "upload_here".tr(),
                    style: const TextStyle(
                      color: Styles.PRIMARY_COLOR,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "thumbnail_desc".tr(),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _validationErrors['image_$formIndex']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildFilesField(
      BuildContext context, int formIndex, List<File> files) {
    final bloc = context.read<PortfolioFormBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "work_files".tr(),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: () async {
            final List<File>? pickedFiles = await _pickFiles();
            if (pickedFiles != null && pickedFiles.isNotEmpty) {
              bloc.add(
                  UpdateFormFiles(formIndex: formIndex, files: pickedFiles));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.attach_file,
                      color: Colors.grey.shade500, size: 32),
                  const SizedBox(height: 8.0),
                  Text(
                    "upload_here".tr(),
                    style: const TextStyle(
                      color: Styles.PRIMARY_COLOR,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "files_desc".tr(),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Text(
            "selected_files".tr(),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8.0),
          ...files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      file.path.split('/').last,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      bloc.add(RemoveFormFile(
                          formIndex: formIndex, fileIndex: index));
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
        const SizedBox(height: 16.0),
      ],
    );
  }

  Future<List<File>?> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        return result.paths.map((path) => File(path!)).toList();
      }
    } catch (e) {
      print("Error picking files: $e");
    }
    return null;
  }

  Widget _buildDateField(
      BuildContext context, int formIndex, String? currentDate) {
    final bloc = context.read<PortfolioFormBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "completion_date".tr(),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => DateTimePicker(
                valueChanged: (DateTime newDate) {
                  final formattedDate =
                  DateFormat('yyyy-MM-dd').format(newDate);
                  bloc.add(UpdateFormField(
                    formIndex: formIndex,
                    fieldName: 'date',
                    value: formattedDate,
                  ));
                },
                label: "completion_date".tr(),
              ),
            );
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentDate?.isNotEmpty == true && currentDate!=null
                      ? currentDate
                      : "completion_date_hint".tr(),
                  style: TextStyle(
                    color: currentDate?.isNotEmpty == true
                        ? Colors.black
                        : Colors.grey.shade500,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.0.h),
      ],
    );
  }
}