// widgets/project_title_field.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';
import '../../../../components/custom_text_form_field.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import 'helper_text_widget.dart';

class ProjectTitleField extends StatelessWidget {
  final TextEditingController controller;

  const ProjectTitleField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: 'add_project.project_title'.tr(),
          isRequired: true,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hint: 'add_project.project_title_hint'.tr(),
          onChanged: (value) {
            context.read<AddProjectBloc>().add(UpdateTitle(title: value));
          },
          validate: (value) {
            if (value == null || value.isEmpty) {
              return 'add_project.field_required'.tr();
            }
            return null;
          },
        ),
        HelperText(text: 'add_project.title_helper'.tr()),
      ],
    );
  }
}