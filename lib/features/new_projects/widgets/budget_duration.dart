// widgets/budget_field.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';
import '../../../../components/custom_text_form_field.dart';
import '../../../data/config/di.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import 'helper_text_widget.dart';

class BudgetField extends StatelessWidget {
  final TextEditingController controller;

  const BudgetField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: 'add_project.budget'.tr(),
          isRequired: true,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hint: 'add_project.budget_hint'.tr(),
          inputType: TextInputType.number,
          onChanged: (value) {
            context.read<AddProjectBloc>().add(UpdateBudget(budget: value));
          },
          validate: (value) {
            if (value == null || value.isEmpty) {
              return 'add_project.field_required'.tr();
            }
            return null;
          },
        ),
        HelperText(text: 'add_project.budget_helper'.tr()),
      ],
    );
  }
}

// widgets/duration_field.dart
class DurationField extends StatelessWidget {
  final TextEditingController controller;

  const DurationField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: 'add_project.duration'.tr(),
          isRequired: true,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hint: 'add_project.duration_hint'.tr(),
          inputType: TextInputType.number,
          onChanged: (value) {
            context.read<AddProjectBloc>().add(
              UpdateDuration(duration: int.tryParse(value) ?? 0),
            );
          },
          validate: (value) {
            if (value == null || value.isEmpty) {
              return 'add_project.field_required'.tr();
            }
            if (int.tryParse(value) == null) {
              return 'add_project.invalid_duration'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}