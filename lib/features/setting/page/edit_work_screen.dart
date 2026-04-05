import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/home/bloc/home_bloc.dart';
import 'package:talent_flow/features/home/bloc/home_event.dart';
import 'package:talent_flow/features/home/bloc/home_state.dart';
import 'package:talent_flow/features/home/model/work_details_model.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_event.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_state.dart';
import 'package:talent_flow/features/new_projects/model/selection_option_model.dart';
import 'package:talent_flow/features/setting/bloc/edit_work_bloc.dart';
import 'package:talent_flow/features/setting/model/edit_work_request_model.dart';
import 'package:talent_flow/features/setting/widgets/multi_select_skills_dialog.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/helpers/date_time_picker.dart';
import 'package:talent_flow/helpers/pickers/view/image_picker_helper.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

class EditWorkScreen extends StatelessWidget {
  const EditWorkScreen({
    super.key,
    required this.workId,
  });

  final int workId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              HomeBloc(homeRepo: sl())..add(WorkDetailsRequested(workId)),
        ),
        BlocProvider(
          create: (_) =>
              SelectionOptionBloc(sl())..add(const SelectionOptionsRequested()),
        ),
        BlocProvider(
          create: (_) => EditWorkBloc(sl()),
        ),
      ],
      child: _EditWorkView(workId: workId),
    );
  }
}

class _EditWorkView extends StatefulWidget {
  const _EditWorkView({
    required this.workId,
  });

  final int workId;

  @override
  State<_EditWorkView> createState() => _EditWorkViewState();
}

class _EditWorkViewState extends State<_EditWorkView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _previewLinkController = TextEditingController();

  File? _selectedImage;
  String? _existingImageUrl;
  String? _selectedDate;
  final List<File> _newFiles = [];
  List<String> _oldFiles = [];
  Map<String, String> _allAvailableSkills = {};
  List<String> _selectedSkillNames = [];
  List<int> _selectedSkillIds = [];
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _previewLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is WorkDetailsLoaded) {
              _hydrateFromWork(state.work);
            }
          },
        ),
        BlocListener<SelectionOptionBloc, SelectionOptionState>(
          listener: (context, state) {
            if (state is SelectionOptionLoaded) {
              final SelectionModel model = state.selectionModel;
              setState(() {
                _allAvailableSkills = model.skills;
                _syncSelectedSkillIds();
              });
            }
          },
        ),
        BlocListener<EditWorkBloc, AppState>(
          listener: (context, state) {
            if (state is Done && state.data == 'updated') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('edit_work.update_success'.tr())),
              );
              CustomNavigator.pop(result: true);
            } else if (state is Done && state.data == 'deleted') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('edit_work.delete_success'.tr())),
              );
              CustomNavigator.pop(result: true);
            } else if (state is Error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('something_went_wrong'.tr())),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: CustomAppBar(
          title: 'edit_work.title'.tr(),
          centerTitle: true,
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, loadState) {
            if (loadState is HomeLoading && !_isInitialized) {
              return const Center(
                child: CircularProgressIndicator(color: Styles.PRIMARY_COLOR),
              );
            }

            if (loadState is HomeFailure && !_isInitialized) {
              return Center(child: Text('something_went_wrong'.tr()));
            }

            return BlocBuilder<EditWorkBloc, AppState>(
              builder: (context, actionState) {
                final isSubmitting = actionState is Loading;
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePicker(),
                          SizedBox(height: 18.h),
                          CustomTextField(
                            label: 'work_title'.tr(),
                            hint: 'work_title_hint'.tr(),
                            controller: _titleController,
                          ),
                          SizedBox(height: 8.h),
                          CustomTextField(
                            label: 'work_description'.tr(),
                            hint: 'work_description_hint'.tr(),
                            controller: _descriptionController,
                            maxLines: 5,
                          ),
                          SizedBox(height: 8.h),
                          _buildSkillsField(context),
                          SizedBox(height: 8.h),
                          CustomTextField(
                            label: 'preview_link'.tr(),
                            hint: 'preview_link_hint'.tr(),
                            controller: _previewLinkController,
                          ),
                          SizedBox(height: 8.h),
                          _buildDateField(context),
                          SizedBox(height: 8.h),
                          _buildFilesSection(),
                          SizedBox(height: 24.h),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => _submit(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Styles.PRIMARY_COLOR,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'edit_work.update'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      isSubmitting ? null : _confirmDelete,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    side: const BorderSide(
                                      color: Color(0xFFDB5353),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'edit_work.delete'.tr(),
                                    style: const TextStyle(
                                      color: Color(0xFFDB5353),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isSubmitting)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color(0x66000000),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Styles.PRIMARY_COLOR,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _hydrateFromWork(WorkDetailsModel work) {
    if (_isInitialized) return;

    setState(() {
      _isInitialized = true;
      _titleController.text = work.title ?? '';
      _descriptionController.text = work.description ?? '';
      _previewLinkController.text = work.previewLink ?? '';
      _selectedDate = work.date;
      _existingImageUrl = work.image;
      _oldFiles = List<String>.from(work.files);
      _selectedSkillNames = List<String>.from(work.skills);
      _syncSelectedSkillIds();
    });
  }

  void _syncSelectedSkillIds() {
    if (_selectedSkillNames.isEmpty) {
      _selectedSkillIds = [];
      return;
    }

    if (_allAvailableSkills.isEmpty) return;

    final normalizedSkills = _selectedSkillNames.map((e) => e.trim()).toSet();
    _selectedSkillIds = _allAvailableSkills.entries
        .where((entry) => normalizedSkills.contains(entry.value.trim()))
        .map((entry) => int.tryParse(entry.key))
        .whereType<int>()
        .toList();
  }

  Widget _buildImagePicker() {
    final imageWidget = _selectedImage != null
        ? Image.file(_selectedImage!, fit: BoxFit.cover)
        : (_existingImageUrl?.trim().isNotEmpty ?? false)
            ? Image.network(
                _existingImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              )
            : _imagePlaceholder();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'thumbnail'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Styles.HEADER,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await ImagePickerHelper.openGallery(
              onGet: (file) {
                setState(() {
                  _selectedImage = file;
                });
              },
            );
          },
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageWidget,
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 42,
          color: Styles.HINT_COLOR,
        ),
      ),
    );
  }

  Widget _buildSkillsField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'project_card_offer.skills'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Styles.HEADER,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _allAvailableSkills.isEmpty
              ? null
              : () async {
                  final selectedNames = await showDialog<List<String>>(
                    context: context,
                    builder: (_) => MultiSelectSkillsDialog(
                      allSkills: _allAvailableSkills.values.toList(),
                      initialSelectedSkills: _selectedSkillNames,
                    ),
                  );

                  if (selectedNames == null) return;

                  setState(() {
                    _selectedSkillNames = selectedNames;
                    _syncSelectedSkillIds();
                  });
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: _selectedSkillNames.isEmpty
                ? Text(
                    'edit_profile.skills_hint'.tr(),
                    style: const TextStyle(color: Styles.HINT_COLOR),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedSkillNames
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            onDeleted: () {
                              setState(() {
                                _selectedSkillNames.remove(skill);
                                _syncSelectedSkillIds();
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    final parsedDate = DateTime.tryParse(_selectedDate ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'completion_date'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Styles.HEADER,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => DateTimePicker(
                initialString: parsedDate?.toIso8601String(),
                isNotEmptyValue: parsedDate != null,
                valueChanged: (date) {
                  setState(() {
                    _selectedDate = DateFormat('yyyy-MM-dd').format(date);
                  });
                },
                label: 'completion_date'.tr(),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (_selectedDate ?? '').isNotEmpty
                      ? _selectedDate!
                      : 'completion_date_hint'.tr(),
                  style: TextStyle(
                    color: (_selectedDate ?? '').isNotEmpty
                        ? Styles.HEADER
                        : Styles.HINT_COLOR,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Styles.HINT_COLOR),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'work_files'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Styles.HEADER,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickPdfFiles,
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
                  Icons.picture_as_pdf_outlined,
                  color: Styles.HINT_COLOR,
                  size: 30,
                ),
                const SizedBox(height: 6),
                Text(
                  'upload_here'.tr(),
                  style: const TextStyle(
                    color: Styles.PRIMARY_COLOR,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PDF',
                  style: TextStyle(color: Styles.HINT_COLOR),
                ),
              ],
            ),
          ),
        ),
        if (_oldFiles.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            'edit_work.existing_files'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Styles.HEADER,
            ),
          ),
          SizedBox(height: 8.h),
          ..._oldFiles.map(
            (file) => _FileItem(
              title: _fileName(file),
              onDelete: () {
                setState(() {
                  _oldFiles.remove(file);
                });
              },
            ),
          ),
        ],
        if (_newFiles.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            'selected_files'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Styles.HEADER,
            ),
          ),
          SizedBox(height: 8.h),
          ..._newFiles.asMap().entries.map(
                (entry) => _FileItem(
                  title: entry.value.path.split('/').last,
                  onDelete: () {
                    setState(() {
                      _newFiles.removeAt(entry.key);
                    });
                  },
                ),
              ),
        ],
      ],
    );
  }

  Future<void> _pickPdfFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (result == null) return;

    setState(() {
      _newFiles.addAll(
        result.paths.whereType<String>().map(File.new),
      );
    });
  }

  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final date = (_selectedDate ?? '').trim();

    if (title.isEmpty ||
        description.isEmpty ||
        date.isEmpty ||
        _selectedSkillIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('edit_work.validation'.tr())),
      );
      return;
    }

    context.read<EditWorkBloc>().add(
          Update(
            arguments: EditWorkRequestModel(
              id: widget.workId,
              title: title,
              description: description,
              date: date,
              previewLink: _previewLinkController.text.trim(),
              skillIds: _selectedSkillIds,
              image: _selectedImage,
              newFiles: _newFiles,
              oldFiles: _oldFiles,
            ),
          ),
        );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('edit_work.delete_confirm_title'.tr()),
            content: Text('edit_work.delete_confirm_body'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'edit_work.delete'.tr(),
                  style: const TextStyle(color: Color(0xFFDB5353)),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;
    final editWorkBloc = context.read<EditWorkBloc>();
    editWorkBloc.add(Delete(arguments: widget.workId));
  }

  String _fileName(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) return url;
    return uri.pathSegments.last;
  }
}

class _FileItem extends StatelessWidget {
  const _FileItem({
    required this.title,
    required this.onDelete,
  });

  final String title;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_outlined,
            color: Styles.HINT_COLOR,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Styles.HEADER,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Color(0xFFDB5353)),
          ),
        ],
      ),
    );
  }
}
