// widgets/advanced_settings.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';
import '../../../../components/custom_text_form_field.dart';

import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';
import 'build_question_section.dart';

class AdvancedSettings extends StatelessWidget {
  const AdvancedSettings({super.key, required this.requiredToBeReceivedContr});
  final TextEditingController requiredToBeReceivedContr;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProjectBloc, AddProjectState>(
      builder: (context, state) {
        return ExpansionTile(
          title: Text(
            'add_project.advanced_settings'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8),
          shape: const Border(),
          collapsedShape: const Border(),
          children: [
            // Questions Section
            const QuestionSection(),
            const SizedBox(height: 16),

            // Required to be received checkbox
            CustomTextField(
              hint: 'add_project.required_to_be_received'.tr(),
              height: 65,
              controller: requiredToBeReceivedContr,
              onChanged: (value) {
                context.read<AddProjectBloc>().add(
                  UpdateRequiredToBeReceived(
                    requiredToBeReceived: value ?? "",
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Similar Projects
            SectionLabel(text: 'add_project.similar_projects'.tr()),
            const SizedBox(height: 8),
            CustomTextField(
              hint: 'add_project.similar_projects_hint'.tr(),
              minLines: 2,
              maxLines: 4,
              onChanged: (value) {
                final projects = value.isEmpty ? <String>[] : [value];
                context.read<AddProjectBloc>().add(
                  UpdateSimilarProjects(similarProjects: projects),
                );
              },
            ),
          ],
        );
      },
    );
  }
}