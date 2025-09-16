// widgets/project_description_field.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';
import '../../../../components/custom_text_form_field.dart';

import '../../../data/config/di.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import 'helper_text_widget.dart';

class ProjectDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const ProjectDescriptionField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: 'add_project.project_description'.tr(),
          isRequired: true,
          trailing: TextButton(
            onPressed: () {
              controller.clear();
              context.read<AddProjectBloc>().add(
                const UpdateDescription(description: ''),
              );
            },
            child: Text(
              'add_project.reset'.tr(),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          hint: 'add_project.project_description_hint'.tr(),
          onSubmit: (value) {
            context.read<AddProjectBloc>().add(
              UpdateDescription(description: value),
            );
          },
          validate: (value) {
            if (value == null || value.isEmpty) {
              return 'add_project.field_required'.tr();
            }
            return null;
          },
        ),
        HelperText(text: 'add_project.description_helper'.tr()),
      ],
    );
  }
}