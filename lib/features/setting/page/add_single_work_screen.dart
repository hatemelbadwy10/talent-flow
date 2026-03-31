import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/setting/repo/add_word_repo.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/helpers/date_time_picker.dart';
import 'package:talent_flow/helpers/pickers/view/image_picker_helper.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/user_completion_guard.dart';

class AddSingleWorkScreen extends StatefulWidget {
  const AddSingleWorkScreen({super.key});

  @override
  State<AddSingleWorkScreen> createState() => _AddSingleWorkScreenState();
}

class _AddSingleWorkScreenState extends State<AddSingleWorkScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _previewLinkController = TextEditingController();

  File? _selectedImage;
  final List<File> _files = [];
  String? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _previewLinkController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(url.trim());
  }

  Future<void> _pickImage() async {
    await ImagePickerHelper.openGallery(
      onGet: (file) {
        setState(() {
          _selectedImage = file;
        });
      },
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty) {
        return;
      }

      setState(() {
        _files.addAll(
          result.files
              .where((element) => element.path != null)
              .map((element) => File(element.path!)),
        );
      });
    } catch (_) {
      _showError('something_went_wrong'.tr());
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => DateTimePicker(
        valueChanged: (date) {
          setState(() {
            _selectedDate = DateFormat('yyyy-MM-dd').format(date);
          });
        },
        label: 'completion_date'.tr(),
      ),
    );
  }

  void _showSuccess(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.ACTIVE,
        borderColor: Colors.transparent,
        isFloating: true,
      ),
    );
  }

  void _showError(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.IN_ACTIVE,
        borderColor: Colors.transparent,
        isFloating: true,
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final previewLink = _previewLinkController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        previewLink.isEmpty ||
        _selectedDate == null ||
        _selectedImage == null) {
      _showError('single_work.validation'.tr());
      return;
    }

    if (!_isValidUrl(previewLink)) {
      _showError('single_work.invalid_link'.tr());
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await sl<AddWorkRepo>().addWork(
      work: WorkItem(
        title: title,
        description: description,
        date: _selectedDate!,
        previewLink: previewLink,
        image: _selectedImage,
        files: _files,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSubmitting = false;
        });
        _showError(failure.error);
      },
      (response) async {
        await UserCompletionGuard.updateStoredFlags(addedWorks: true);
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });

        final message = response.data is Map && response.data['message'] != null
            ? response.data['message'].toString()
            : 'single_work.success'.tr();

        _showSuccess(message);
        CustomNavigator.pop(result: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: CustomAppBar(
        title: 'settings_screen.upload_work'.tr(),
        centerTitle: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'work_title'.tr(),
                    hint: 'work_title_hint'.tr(),
                    controller: _titleController,
                  ),
                  const SizedBox(height: 8),
                  _buildImageField(),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'work_description'.tr(),
                    hint: 'work_description_hint'.tr(),
                    controller: _descriptionController,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 8),
                  _buildFilesField(),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'preview_link'.tr(),
                    hint: 'preview_link_hint'.tr(),
                    controller: _previewLinkController,
                    inputType: TextInputType.url,
                  ),
                  const SizedBox(height: 8),
                  _buildDateField(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'single_work.submit'.tr(),
              isLoading: _isSubmitting,
              isActive: !_isSubmitting,
              onTap: _isSubmitting ? null : _submit,
              radius: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildImageField() {
    final fileName = _selectedImage?.path.split('/').last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'thumbnail'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Styles.HEADER,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: Styles.HINT_COLOR,
                    size: 30,
                  ),
                const SizedBox(height: 10),
                Text(
                  fileName ?? 'upload_here'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Styles.PRIMARY_COLOR,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'thumbnail_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Styles.HINT_COLOR,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'work_files'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Styles.HEADER,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.attach_file,
                  color: Styles.HINT_COLOR,
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  'upload_here'.tr(),
                  style: const TextStyle(
                    color: Styles.PRIMARY_COLOR,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'files_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Styles.HINT_COLOR,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._files.asMap().entries.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        color: Styles.HINT_COLOR,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Styles.HEADER),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeFile(entry.key),
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Styles.HINT_COLOR,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildDateField() {
    final hasDate = (_selectedDate ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'completion_date'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Styles.HEADER,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasDate ? _selectedDate! : 'completion_date_hint'.tr(),
                    style: TextStyle(
                      color: hasDate ? Styles.HEADER : Styles.HINT_COLOR,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Styles.HINT_COLOR,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
