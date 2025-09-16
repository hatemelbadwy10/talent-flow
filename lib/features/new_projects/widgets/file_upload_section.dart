// widgets/file_upload_section.dart
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';
import '../../../../components/custom_text_form_field.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';
import 'helper_text_widget.dart';

class FileUploadSection extends StatelessWidget {
  final TextEditingController filesDescriptionController;

  const FileUploadSection({
    super.key,
    required this.filesDescriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: 'add_project.attachments'.tr()),
        const SizedBox(height: 8),
        DottedBorder(
          color: Colors.grey.shade400,
          strokeWidth: 1.5,
          dashPattern: const [8, 4],
          radius: const Radius.circular(8),
          borderType: BorderType.RRect,
          child: Builder(
            builder: (context) => InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showImagePicker(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.grey.shade600,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        text: 'add_project.upload_text'.tr(),
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'add_project.upload_or_drag'.tr(),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'add_project.file_formats'.tr(),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TextField for description
                    BlocBuilder<AddProjectBloc, AddProjectState>(
                      builder: (context, state) {
                        return CustomTextField(
                          controller: filesDescriptionController,
                          hint: 'add_project.files_description_hint'.tr(),
                          onChanged: (value) {
                            context.read<AddProjectBloc>().add(
                              UpdateFilesDescription(
                                filesDescription: value.isEmpty ? null : value,
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Display uploaded files
                    BlocBuilder<AddProjectBloc, AddProjectState>(
                      builder: (context, state) {
                        if (state.files.isNotEmpty) {
                          return Column(
                            children: state.files.map((file) {
                              return ListTile(
                                leading: const Icon(Icons.insert_drive_file),
                                title: Text(file.path.split('/').last),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    final List<File> updatedFiles =
                                    List.from(state.files)..remove(file);
                                    context.read<AddProjectBloc>().add(
                                      UpdateFiles(files: updatedFiles),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        HelperText(text: 'add_project.upload_helper'.tr()),
      ],
    );
  }

  void _showImagePicker(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title:  Text('take_a_photo'.tr()),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImageFromCamera(parentContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title:  Text('choose_from_gallery'.tr()),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImageFromGallery(parentContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImageFromCamera(BuildContext parentContext) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final file = File(image.path);
        parentContext.read<AddProjectBloc>().add(UpdateFiles(
          files: List<File>.from(
            parentContext.read<AddProjectBloc>().state.files,
          )..add(file),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _pickImageFromGallery(BuildContext parentContext) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        parentContext.read<AddProjectBloc>().add(UpdateFiles(
          files: List<File>.from(
            parentContext.read<AddProjectBloc>().state.files,
          )..add(file),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
}
